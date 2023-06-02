#include "addt.h"
#include "ui_addt.h"

addt::addt(QWidget *parent, QSqlDatabase database) :
    ui(new Ui::addt)
{
    ui->setupUi(this);
    db = database;
    query = new QSqlQuery(database);


}

addt::~addt()
{
    delete ui;
}

// SUBMIT

void addt::on_pushButton_clicked()
{
    QString name = ui->lineEdit->text();
    QString surname = ui->lineEdit_2->text();
    int dnumber = ui->lineEdit_3->text().toInt();
    QString email = ui->lineEdit_4->text();
    QString cell = ui->lineEdit_5->text();
    QDateTime atime = ui->dateTimeEdit->dateTime();
    QDateTime ltime = ui->dateTimeEdit_2->dateTime();
    int shifttime = ui->lineEdit_6->text().toInt();

    if (!(name.trimmed().isEmpty() && surname.trimmed().isEmpty() && dnumber == NULL && email.trimmed().isEmpty() && cell.trimmed().isEmpty()
          && atime.isNull() && ltime.isNull() && shifttime == NULL))
    {
        query = new QSqlQuery(db);

        query->prepare("SELECT "
                    "company.insert_data(:name, :surname, :dnumber, :email, :cell, :atime, :ltime, :stime)");

        query->bindValue(":name", name);
        query->bindValue(":surname", surname);
        query->bindValue(":dnumber", dnumber);
        query->bindValue(":email", email);
        query->bindValue(":cell", cell);
        query->bindValue(":atime", atime);
        query->bindValue(":ltime", ltime);
        query->bindValue(":stime", shifttime);

        query->exec();

        // qDebug() << query->lastQuery();
        // qDebug() << query->lastError();
        //qDebug() << name << surname << dnumber << email << cell << atime<< ltime << shifttime;
    }
    else
    {
        QMessageBox msg;
        msg.setText("lines are empty");
        msg.exec();
    }

}

// UPDATE DEPARTMENTS

void addt::on_pushButton_2_clicked()
{
    QString dname = ui->lineEdit_7->text();
    QString sname = ui->lineEdit_8->text();
    QString pname = ui->lineEdit_9->text();

    query = new QSqlQuery(db);

    query->prepare("SELECT company.insert_department(:name, :sname, :pname)");

    query->bindValue(":name", dname);
    query->bindValue(":sname", sname);
    query->bindValue(":pname", pname);

    query->exec();

    qDebug() << dname << sname << pname;

    qDebug() << query->lastQuery();
    qDebug() << query->lastError();
}

