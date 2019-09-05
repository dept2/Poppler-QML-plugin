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

#include <pdfModel.h>
#include <pageImageProvider.h>

#include <poppler/qt5/poppler-qt5.h>
#include <QDebug>
#include <QQmlEngine>
#include <QQmlContext>

PdfModel::PdfModel(QQuickItem* parent)
  : QQuickItem(parent)
{}

void PdfModel::setPath(QString& pathName)
{
  if (pathName.isEmpty())
  {
    DEBUG << "Can't load the document, path is empty.";
    emit error("Can't load the document, path is empty.");
    return;
  }

  this->path = pathName;
  emit pathChanged(pathName);

  if (!loadDocument(pathName))
    return;

  loadProvider();
  emit loadedChanged();
}

QStringList PdfModel::getPages() const
{
  return pages;
}

int PdfModel::loadDocument(QString& pathName)
{
  DEBUG << "Loading document...";

  clear();
  this->document = Poppler::Document::load(pathName);

  if (!document || document->isLocked())
  {
    DEBUG << "ERROR : Can't open the document located at " + pathName;
    emit error("Can't open the document located at " + pathName);
    delete document;
    document = nullptr;
    return 0;
  }

  DEBUG << "Document loaded successfully !";

  document->setRenderHint(Poppler::Document::Antialiasing, true);
  document->setRenderHint(Poppler::Document::TextAntialiasing, true);

  return 1;
}

bool PdfModel::getLoaded() const
{
  return document != nullptr;
}

void PdfModel::loadProvider()
{
  DEBUG << "Loading image provider...";
  QQmlEngine* engine = QQmlEngine::contextForObject(this)->engine();

  const QString& prefix = QString::number(quintptr(this));
  providerName = "poppler" + prefix;
  engine->addImageProvider(providerName, new PageImageProvider(document));

  const int pagesNum = document->numPages();
  for (auto i = 0; i < pagesNum; ++i)
    pages.append("image://" + providerName + "/page/" + QString::number(i + 1));

  emit pagesChanged();
  DEBUG << "Image provider loaded successfully !" << qPrintable("(" + providerName + ")");
}

void PdfModel::clear()
{
  if (!providerName.isEmpty())
  {
    QQmlEngine* engine = QQmlEngine::contextForObject(this)->engine();
    if (engine)
      engine->removeImageProvider(providerName);
  }

  delete document;
  document = nullptr;
  emit loadedChanged();
  pages.clear();
  emit pagesChanged();
}

PdfModel::~PdfModel()
{
  clear();
}
