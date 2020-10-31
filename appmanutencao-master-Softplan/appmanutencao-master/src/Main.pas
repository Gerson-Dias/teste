unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfMain = class(TForm)
    btDatasetLoop: TButton;
    btThreads: TButton;
    btStreams: TButton;
    procedure btDatasetLoopClick(Sender: TObject);
    procedure btStreamsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TratarExcecao(Sender: TObject; E: Exception);
    procedure btThreadsClick(Sender: TObject);
  private

  public

  end;

var
  fMain: TfMain;

implementation

uses
  DatasetLoop, ClienteServidor, Threads;

{$R *.dfm}

procedure TfMain.btDatasetLoopClick(Sender: TObject);
begin
  fDatasetLoop.Show;
end;

procedure TfMain.btStreamsClick(Sender: TObject);
begin
  fClienteServidor.Show;
end;


procedure TfMain.btThreadsClick(Sender: TObject);
begin
 fThreads.Show;
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  Application.OnException := TratarExcecao;
end;

procedure TfMain.TratarExcecao(Sender: TObject; E: Exception);
var tfLogErro: TextFile;
    sFileName: String;
begin
  try
    sFileName := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'LogErros.Log';
    AssignFile(tfLogErro, sFileName);
    if FileExists(sFileName) then
      Append(tfLogErro)
    else
      Rewrite(tfLogErro);
    WriteLn(tfLogErro,FormatDateTime('dd/mm/yyyy hh:mm:ss', Now())+ ' Erro Original: ' + E.Message + ' Classe do Erro: ' + E.ClassName );
    Flush(tfLogErro);
    CloseFile(tfLogErro);

    ShowMessage('Exceção Global' +#13 + #13 +
                'Erro Original: ' + E.Message + #13 +
                'Classe do Erro: ' + E.ClassName );
  except on E:Exception do
    ShowMessage('Não foi possível gerar Log de Erros do Sistema' + #13 + E.Message);
  end;
end;



end.
