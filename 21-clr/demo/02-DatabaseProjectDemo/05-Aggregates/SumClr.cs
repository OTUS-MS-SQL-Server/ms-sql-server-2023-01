using System;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

/// <summary>
/// Аналог встроенной SUM().
/// </summary>
[Serializable]
[SqlUserDefinedAggregate(Format.Native)]
public struct SumClr
{
    private SqlInt32 _sum;

    public void Init()
    {
        _sum = new SqlInt32(0);
    }

    public void Accumulate(SqlInt32 value)
    {
        if (value.IsNull)
            return;

        _sum += value;
    }

    public void Merge(SumClr group)
    {
        _sum += group._sum;
    }

    public SqlInt32 Terminate()
    {
        return _sum;
    }
}