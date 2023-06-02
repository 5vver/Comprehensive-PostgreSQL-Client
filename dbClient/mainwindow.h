#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QDateTime>
#include <QDebug>
#include <QMessageBox>
#include <QSqlDatabase>
#include <QtSql>
#include <QString>
#include <QSqlQuery>

#include <clientadmin.h>
#include <clientuser.h>

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();


    QSqlDatabase db;
    QSqlQuery *query;



    ClientUser *CU;
    ClientAdmin *CA;

private:
    Ui::MainWindow *ui;


private slots:

    void on_pushButton_clicked();
};
#endif // MAINWINDOW_H
