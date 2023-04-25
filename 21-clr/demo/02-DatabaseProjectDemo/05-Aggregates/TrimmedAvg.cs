using System;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

/// <summary>
/// Усеченное среднее.
/// Среднее из чисел за исключением самого большого
/// и самого маленького числа.
/// </summary>
[Serializable]
[SqlUserDefinedAggregate(Format.Native)]
public struct TrimmedAvg 
{
    // агрегат делается в виде класса с методами:
    // * Init
    // * Accumulate
    // * Merge
    // * Terminate

    private int _numValues;
    private SqlDouble _totalValue;
    private SqlDouble _minValue;
    private SqlDouble _maxValue;

    public void Init()
    {
        _numValues = 0;
        _totalValue = 0;
        _minValue = SqlDouble.MaxValue;
        _maxValue = SqlDouble.MinValue;
    }

    public void Accumulate(SqlDouble value)
    {
        if (!value.IsNull)
        {
            _numValues++;
            _totalValue += value.Value;

            if (value < _minValue)
            {
                _minValue = value.Value;
            }

            if (value > _maxValue)
            {
                _maxValue = value.Value;
            }
        }
    }

    public void Merge(TrimmedAvg group)
    {
        if (group._numValues > 0)
        {
            _numValues += group._numValues;
            _totalValue += group._totalValue;

            if (group._minValue < _minValue)
            {
                _minValue = group._minValue;
            }

            if (group._maxValue > _maxValue)
            {
                _maxValue = group._maxValue;
            }
        }
    }

    public SqlDouble Terminate()
    {
        if (_numValues < 3)
        {
            return SqlDouble.Null;
        }
        else
        {
            _numValues -= 2;
            _totalValue -= _minValue;
            _totalValue -= _maxValue;

            return _totalValue / _numValues;
        }
    }
}
