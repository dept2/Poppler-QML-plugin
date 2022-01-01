/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Author: Anthony Granger <grangeranthony@gmail.com>
 */

// Local
#include "pdfModel.h"
#include "pageImageProvider.h"

// Poppler
#include <poppler/qt6/poppler-qt6.h>

// Qt
#include <QDebug>
#include <QQmlEngine>
#include <QQmlContext>

// stl
#include <memory>


static QVariantMap convertDestination(const Poppler::LinkDestination& destination)
{
  QVariantMap result;
  result["page"] = destination.pageNumber() - 1;
  result["top"] = destination.top();
  result["left"] = destination.left();
  return result;
}


PdfModel::PdfModel(QObject* parent)
  : QObject(parent)
{}


void PdfModel::setPath(QString& pathName)
{
  if (pathName == path)
    return;

  if (pathName.isEmpty())
  {
    DEBUG << "Can't load the document, path is empty.";
    emit error("Can't load the document, path is empty.");
    return;
  }

  this->path = pathName;
  emit pathChanged(pathName);

  // Load document
  clear();
  DEBUG << "Loading document...";
  document = Poppler::Document::load(path);

  if (!document || document->isLocked())
  {
    DEBUG << "ERROR : Can't open the document located at " + pathName;
    emit error("Can't open the document located at " + pathName);
    document = nullptr;
    return;
  }

  // Create image provider
  document->setRenderHint(Poppler::Document::Antialiasing, true);
  document->setRenderHint(Poppler::Document::TextAntialiasing, true);
  loadProvider();

  // Fill in pages data
  const int numPages = document->numPages();
  for (int i = 0; i < numPages; ++i)
  {
    std::unique_ptr<Poppler::Page> page(document->page(i));

    QVariantMap pageData;
    pageData["image"] = "image://" + providerName + "/page/" + QString::number(i + 1);
    pageData["size"] = page->pageSizeF();

    QVariantList pageLinks;
    auto links = page->links();
    for (const auto& link : links)
    {
      if (link->linkType() == Poppler::Link::Goto)
      {
        auto gotoLink = static_cast<Poppler::LinkGoto*>(link.get());
        if (!gotoLink->isExternal())
        {
          pageLinks.append(QVariantMap{{ "rect", link->linkArea().normalized() }, { "destination", convertDestination(gotoLink->destination()) }});
        }
      }
    }
    pageData["links"] = pageLinks;

    pages.append(pageData);
  }
  emit pagesChanged();

  DEBUG << "Document loaded successfully";
  emit loadedChanged();
}


QVariantList PdfModel::getPages() const
{
  return pages;
}


bool PdfModel::getLoaded() const
{
  return document != nullptr;
}


QVariantList PdfModel::search(int page, const QString& text, Qt::CaseSensitivity caseSensitivity)
{
  QVariantList result;
  if (document == nullptr)
  {
    qWarning() << "Poppler plugin: no document to search";
    return result;
  }

  if (page >= document->numPages() || page < 0)
  {
    qWarning() << "Poppler plugin: search page" << page << "isn't in a document";
    return result;
  }

  std::unique_ptr<Poppler::Page> p(document->page(page));
  auto searchResult = p->search(text, caseSensitivity == Qt::CaseInsensitive ? Poppler::Page::IgnoreCase : static_cast<Poppler::Page::SearchFlag>(0));

  auto pageSize = p->pageSizeF();
  for (const auto& r : searchResult)
  {
    result.append(QRectF(r.left() / pageSize.width(), r.top() / pageSize.height(), r.width() / pageSize.width(), r.height() / pageSize.height()));
  }
  return result;
}


void PdfModel::loadProvider()
{
  DEBUG << "Loading image provider...";
  QQmlEngine* engine = QQmlEngine::contextForObject(this)->engine();

  const QString& prefix = QString::number(quintptr(this));
  providerName = "poppler" + prefix;
  engine->addImageProvider(providerName, new PageImageProvider(document.get()));

  DEBUG << "Image provider loaded successfully !" << qPrintable("(" + providerName + ")");
}


void PdfModel::clear()
{
  if (!providerName.isEmpty())
  {
    QQmlEngine* engine = QQmlEngine::contextForObject(this)->engine();
    if (engine)
      engine->removeImageProvider(providerName);
    providerName.clear();
  }

  document = nullptr;
  emit loadedChanged();
  pages.clear();
  emit pagesChanged();
}


PdfModel::~PdfModel()
{
  clear();
}
