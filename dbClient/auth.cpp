#include "auth.h"
#include "ui_auth.h"

Auth::Auth(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::Auth)
{
    ui->setupUi(this);


}

Auth::~Auth()
{
    delete ui;
}

void Auth::on_pushButton_clicked()
{



}

