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

#ifndef PDFMODEL_H
#define PDFMODEL_H

#include <QQuickItem>
#include <poppler/qt5/poppler-qt5.h>

#define DEBUG if (qgetenv("POPPLERPLUGIN_DEBUG") == "1") qDebug() << "Poppler plugin:"

class PdfModel : public QQuickItem
{
  Q_OBJECT
  Q_DISABLE_COPY(PdfModel)

  public:
    explicit PdfModel(QQuickItem* parent = nullptr);
    virtual ~PdfModel();

    Q_PROPERTY(QString path READ getPath WRITE setPath NOTIFY pathChanged)
    Q_PROPERTY(bool loaded READ getLoaded NOTIFY loadedChanged)
    Q_PROPERTY(QStringList pages READ getPages NOTIFY pagesChanged)

    void setPath(QString& pathName);
    QString getPath() const { return path; }
    QStringList getPages() const;
    bool getLoaded() const;

  signals:
    void pathChanged(const QString& newPath);
    void loadedChanged();
    void error(const QString& errorMessage);
    void pagesChanged();


  private:
    int loadDocument(QString& pathName);
    void loadProvider();
    void clear();

    Poppler::Document* document = nullptr;
    QString providerName;
    QString path;
    QStringList pages;
};

QML_DECLARE_TYPE(PdfModel)

#endif // PDFMODEL_H
