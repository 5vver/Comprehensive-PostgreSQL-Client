#ifndef ADDT_H
#define ADDT_H

#include <QWidget>
#include <QSqlDatabase>
#include <QtSql>
#include <QString>
#include <QMap>
#include <QSqlQuery>
#include <QTableView>
#include <QMessageBox>

namespace Ui {
class addt;
}

class addt : public QWidget
{
    Q_OBJECT

public:
    explicit addt(QWidget *parent = nullptr, QSqlDatabase database = QSqlDatabase());
    ~addt();

    QSqlQuery *query;

    QSqlDatabase db;

private slots:
    void on_pushButton_clicked();

    void on_pushButton_2_clicked();

private:
    Ui::addt *ui;
};

#endif // ADDT_H
