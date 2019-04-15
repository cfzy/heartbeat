unit uPublic;

interface

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

implementation

end.
