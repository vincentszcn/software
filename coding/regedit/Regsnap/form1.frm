VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   3195
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   4680
   LinkTopic       =   "Form1"
   ScaleHeight     =   3195
   ScaleWidth      =   4680
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command5 
      Caption         =   "Init"
      Height          =   495
      Left            =   1200
      TabIndex        =   4
      Top             =   120
      Width           =   2295
   End
   Begin VB.CommandButton Command4 
      Caption         =   "Show RegSnap"
      Height          =   495
      Left            =   1200
      TabIndex        =   3
      Top             =   2640
      Width           =   2295
   End
   Begin VB.CommandButton Command3 
      Caption         =   "Compare"
      Height          =   375
      Left            =   2880
      TabIndex        =   2
      Top             =   1440
      Width           =   1335
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Save snap2"
      Height          =   375
      Left            =   360
      TabIndex        =   1
      Top             =   1680
      Width           =   1335
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Save snap1"
      Height          =   375
      Left            =   360
      TabIndex        =   0
      Top             =   1080
      Width           =   1335
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim rsobj As Object

Private Sub Command1_Click()
Call rsobj.snap(0, "", 1, "Created via Automation")
rsobj.saveas ("au1.rgs")
MsgBox (rsobj.getRepStr)
End Sub

Private Sub Command2_Click()
Call rsobj.snap(0, "", 1, "Created via Automation")
rsobj.saveas ("au2.rgs")
MsgBox (rsobj.getRepStr)
End Sub

Private Sub Command3_Click()
Call rsobj.compare("au1.rgs", "au2.rgs", "aucmp.txt", 1)
MsgBox ("Report file aucmp.txt generated")
End Sub

Private Sub Command4_Click()
Call rsobj.appShow(1)
End Sub

Private Sub Command5_Click()
Set rsobj = CreateObject("regsnap.document")
MsgBox ("RegSnap inited ok")
End Sub

