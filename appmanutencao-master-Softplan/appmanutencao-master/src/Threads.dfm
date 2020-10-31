object fThreads: TfThreads
  Left = 0
  Top = 0
  Caption = 'fThreads'
  ClientHeight = 344
  ClientWidth = 447
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 31
    Top = 27
    Width = 99
    Height = 13
    Caption = 'N'#250'meros de Threads'
  end
  object Label2: TLabel
    Left = 31
    Top = 54
    Width = 100
    Height = 13
    Caption = 'Tempo Milissegundos'
  end
  object ProgressBar1: TProgressBar
    Left = 32
    Top = 78
    Width = 353
    Height = 17
    TabOrder = 0
  end
  object btnCriarThreads: TButton
    Left = 310
    Top = 22
    Width = 75
    Height = 25
    Caption = 'Criar Threads'
    TabOrder = 1
    OnClick = btnCriarThreadsClick
  end
  object edtQtd: TEdit
    Left = 136
    Top = 24
    Width = 121
    Height = 21
    TabOrder = 2
    Text = '4'
  end
  object memProcessamento: TMemo
    Left = 32
    Top = 122
    Width = 353
    Height = 192
    TabOrder = 3
  end
  object edtTempo: TEdit
    Left = 136
    Top = 51
    Width = 121
    Height = 21
    TabOrder = 4
    Text = '100'
  end
end
