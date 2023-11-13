#include "File.h"

#include <QFile>
#include <QDebug>

File::File()
{
    connect(this, SIGNAL(sourceChanged()), this, SLOT(readFile()));
}

void File::setSource(const QString &source)
{
    m_source = source;
    emit sourceChanged();
}

QString File::source() const
{
    return m_source;
}

void File::setText(const QString &text)
{
    QFile file(m_source);
    if (!file.open(QIODevice::WriteOnly)) {
        m_text = "";
        qDebug() << "Error:" << m_source << "open failed! File not yet created.";
    }
    else {
        qint64 byte = file.write(text.toUtf8());
        if (byte != text.toUtf8().size()) {
            m_text = text.toUtf8().left(byte);
            qDebug() << "Error:" << m_source << "open failed!";
        }
        else {
            m_text = text;
        }

        file.close();
    }

    emit textChanged();
}

void File::readFile()
{
    QFile file(m_source);
    if (!file.open(QIODevice::ReadOnly)) {
        m_text = "";
        qDebug() << "Error:" << m_source << "open failed!";
    }

    m_text = file.readAll();
    emit textChanged();
}

QString File::text() const
{
    return m_text;
}
