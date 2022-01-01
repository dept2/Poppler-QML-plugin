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
#include "pageImageProvider.h"
#include "pdfModel.h"

// Qt
#include <QElapsedTimer>
#include <QDebug>


PageImageProvider::PageImageProvider(Poppler::Document* pdfDocument)
  : QQuickImageProvider(QQuickImageProvider::Image, QQmlImageProviderBase::ForceAsynchronousImageLoading)
  , document(pdfDocument)
{}


QImage PageImageProvider::requestImage(const QString& id, QSize* size, const QSize& requestedSize)
{
  QElapsedTimer t;
  t.start();

  QString type = id.section("/", 0, 0);
  QImage result;

  if (document && type == "page")
  {
    int numPage = id.section("/", 1, 1).toInt();

    DEBUG << "Page" << numPage << "requested";

    auto page = document->page(numPage - 1);

    QSizeF pageSize = page->pageSizeF();
    DEBUG << "Requested size:" << requestedSize << "Page size:" << pageSize;

    double res = requestedSize.width() / (pageSize.width() / 72);
    DEBUG << "Rendering resolution :" << res << "dpi";

    result = page->renderToImage(res, res);
    *size = result.size();

    DEBUG << "Page rendered in" << t.elapsed() << "ms." << result.size();
  }

  return result;
}
