#ifndef CLIENTADMIN_H
#define CLIENTADMIN_H

#include <QWidget>
#include <QSqlDatabase>
#include <QtSql>
#include <QString>
#include <QMap>
#include <QSqlQuery>
#include <QTableView>
#include <QMessageBox>

#include <updt.h>
#include <addt.h>

namespace Ui {
class ClientAdmin;
}

class ClientAdmin : public QWidget
{
    Q_OBJECT

public:
    explicit ClientAdmin(QWidget *parent = nullptr);
    ClientAdmin(QWidget *parent = nullptr, QSqlDatabase database = QSqlDatabase());
    ~ClientAdmin();

    bool dslotSelected = false;

    bool slotSelected = false;
    QList<QString> rowvals;
    QString rowval;


    QMap<QString, QTableView * > views;

    QString EMPLOYEE_TABLE = "Employee";
    QString DEPARTMENTS_TABLE = "Department";

    QSqlQueryModel *model = new QSqlQueryModel;
    QSqlQuery *query;

    QSqlDatabase db;

    Updt *updatepage;
    addt *addpage;

private slots:
    void on_mainTView_clicked(const QModelIndex &index);

    void on_pushButton_2_clicked();

    void on_mainDTView_clicked(const QModelIndex &index);

    void on_pushButton_3_clicked();

    void on_pushButton_clicked();

    void on_pushButton_4_clicked();

    void on_pushButton_5_clicked();

private:
    Ui::ClientAdmin *ui;
    void ShowTable(QMap<QString, QTableView *> &views);
};

#endif // CLIENTADMIN_H
