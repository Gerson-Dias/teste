unit Threads;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, SyncObjs;

type

  TfThreads = class(TForm)
    ProgressBar1: TProgressBar;
    btnCriarThreads: TButton;
    edtQtd: TEdit;
    memProcessamento: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    edtTempo: TEdit;
    procedure btnCriarThreadsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
type
  TTesteThread = class(TThread)
    private
      FLock: TCriticalSection;
    constructor Create(ALock: TCriticalSection);
    protected
      procedure Execute; override;
    public
  end;

var
  fThreads: TfThreads;
  TesteThreads : Array of TTesteThread;

const TOTAL_ITERACAO = 100;

implementation

{$R *.dfm}

{TTesteThread}
constructor TTesteThread.Create(ALock: TCriticalSection);
begin
  FLock := ALock;
  inherited Create;
end;

procedure TTesteThread.Execute;
var iTempo, iIteracao: Integer;
begin
  fThreads.memProcessamento.Lines.Add(IntToStr(ThreadID) + ' Iniciando processamento');

  for iIteracao := 0 to TOTAL_ITERACAO-1 do
  begin
    fThreads.ProgressBar1.Position := fThreads.ProgressBar1.Position + 1;
    iTempo := Random(StrToIntDef(fThreads.EdtTempo.Text,0));
    Sleep(iTempo);
  end;

  fThreads.memProcessamento.Lines.Add(IntToStr(ThreadID) + ' Processamento finalizado');
end;

procedure TfThreads.btnCriarThreadsClick(Sender: TObject);
var iQtdThreads, i : Integer;
    Lock: TCriticalSection;
begin
  iQtdThreads := StrToIntDef(edtQtd.Text,1);
  SetLength(TesteThreads, iQtdThreads);
  Lock := TCriticalSection.Create;

  memProcessamento.Lines.Clear;
  ProgressBar1.Max      := iQtdThreads * TOTAL_ITERACAO;
  ProgressBar1.Position := 0;

  for i := 0 to iQtdThreads-1 do
    TesteThreads[i] := TTesteThread.Create(Lock);

  WaitForMultipleObjects(iQtdThreads, @TesteThreads, True, INFINITE);
  Application.ProcessMessages;

  for i := 0 to iQtdThreads-1 do
    TesteThreads[I].Free;

  Lock.Free;

  // Estranhamente às vezes mesmo ocorrendo todas iterações do for, o progresso não é atualizado.
  // Forçar o final do progresso
  ProgressBar1.Position := ProgressBar1.Max;
end;

end.
