#ifndef AUTH_H
#define AUTH_H

#include <QWidget>
#include <QDebug>
#include <QSqlDatabase>
#include <QtSql>
#include <QSqlQuery>
#include <QString>
#include <QMessageBox>



namespace Ui {
class Auth;
}

class Auth : public QWidget
{
    Q_OBJECT



public:
    explicit Auth(QWidget *parent = nullptr);
    ~Auth();

    QSqlDatabase db;
    QSqlQuery *query;

    bool isConnected = false;

signals:
    void dbConnected();

private slots:
    void on_pushButton_clicked();

private:
    Ui::Auth *ui;
};

#endif // AUTH_H
