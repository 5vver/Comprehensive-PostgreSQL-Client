#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "auth.h"
//#include "ui_auth.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);


}


MainWindow::~MainWindow()
{
    delete ui;

}

// log in clicked

void MainWindow::on_pushButton_clicked()
{
    //ui->lineEdit->setText("companyadmin");
    //ui->lineEdit_2->setText("12345");

    QString log = ui->lineEdit->text();
    QString pass = ui->lineEdit_2->text();
    QMessageBox msg;

    db = QSqlDatabase::addDatabase("QPSQL");

    db.setHostName("localhost");
    db.setUserName(log);
    db.setPassword(pass);
    db.setPort(5432);
    db.setDatabaseName("postgres");


    if (db.open())
    {
        qDebug() << "db connected" << Qt::endl;

        msg.setText("Success!");
        msg.exec();

        this->close();
    }
    else
    {
        qDebug() << "db connection failed" << Qt::endl;
        ui->lineEdit->clear();
        ui->lineEdit_2->clear();
        msg.setText("Connection failed!");
        msg.exec();
        return;

    }

    // role check

    bool rolsuper = false;
    query = new QSqlQuery(db);


    query->prepare("SELECT rolsuper FROM pg_roles WHERE rolname = :username");
    query->bindValue(":username", log);
    query->exec();

    while (query->next())
        rolsuper = query->value("rolsuper").toBool();

    //qDebug() << rolsuper;
    if (!rolsuper)
    {
        CU = new ClientUser(this, db);
        CU->show();
    }
    else
    {
        CA = new ClientAdmin(this, db);
        CA->show();
    }
}

