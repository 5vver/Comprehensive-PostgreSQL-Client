#ifndef ADD_H
#define ADD_H

#include <QWidget>
#include <QSqlDatabase>
#include <QtSql>
#include <QString>
#include <QMap>
#include <QSqlQuery>
#include <QTableView>
#include <QMessageBox>

namespace Ui {
class Update;
}

class Add : public QWidget
{
    Q_OBJECT

public:
    explicit Add(QWidget *parent = nullptr, QSqlDatabase database = QSqlDatabase());
    ~Add();

    QSqlQueryModel *model = new QSqlQueryModel;
    QSqlQuery *query;

    QSqlDatabase db;

private slots:
    void on_pushButton_clicked();

private:
    Ui::Add *ui;
};

#endif // ADD_H
