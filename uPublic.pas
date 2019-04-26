unit uPublic;

interface

uses System.SysUtils;

const
  IOC_IN = $80000000;
  IOC_VENDOR = $18000000;
  IOC_out = $40000000;
  SIO_KEEPALIVE_VALS = IOC_IN or IOC_VENDOR or 4;
  DATA_BUFSIZE = 8192;

  // 定义 KeepAlive 数据结构
type
  TTCP_KEEPALIVE = packed record
    onoff: integer;
    keepalivetime: integer;
    keepaliveinterval: integer;
  end;

function yyyyMMddHHmmss(): string;
function yyyyMMddHHmmsszzz(): string;

implementation

function yyyyMMddHHmmss: string;
begin
  Result := FormatDateTime('[yyyy-MM-dd HH:mm:ss]', Now());
end;

function yyyyMMddHHmmsszzz: string;
begin
  Result := FormatDateTime('[yyyy-MM-dd HH:mm:ss.zzz]', Now());
end;

end.
