using System;
using System.Data.SqlTypes;
using System.IO;
using System.Text.RegularExpressions;
using Microsoft.SqlServer.Server;

/*
SqlUserDefinedType:

* Format - обязательный, определяет метод 
* сериализации,
    UserDefined - IBinarySerialize, 
    Native - только для struct с "простыми" полями 

* IsByteOrdered - по умолчанию true

* IsFixedLength - по умолчанию false

* MaxByteSize - макс.размер, которого может достигать тип:
    -1 - неограничен (2ГБ, с SQL Server 2008)
    1  - 8000
*/

[Serializable]
[SqlUserDefinedType(
    Format.UserDefined,
    IsByteOrdered = true,
    IsFixedLength = false,
    MaxByteSize = 11)]
public class PhoneNumber : INullable, IBinarySerialize
{
    // INullable нужен для правильной 
    // обработки NULL (см. SqlTypesNull.cs)

    // Поле для хранения значения
    private string _number;

    // Пользователи будут работать 
    // через свойство, здесь же валидация
    public SqlString Number
    {
        get
        {
            return new SqlString(_number);
        }

        set
        {
            if (value == SqlString.Null)
            {
                _number = string.Empty;
                return;
            }

            string str = (string)value;

            if (Regex.IsMatch(str, "[0-9]{10}"))
            {
                _number = str;
            }
            else
            {
                throw new ArgumentException(
                    "Phone numbers must be 10 digits.");
            }
        }
    }

    public override string ToString()
    {
        return _number;
    }

    public string ToFormattedString()
    {
        return string.Format(
            "({0}) {1}-{2}-{3}",
            _number.Substring(0, 3),
            _number.Substring(3, 3),
            _number.Substring(6, 2),
            _number.Substring(8, 2));
    }

    public bool IsNull // INullable
    {
        // Это тот же Null - SqlString.IsNull, SqlInt32.IsNull
        get { return string.IsNullOrEmpty(_number); }
    }

    public static PhoneNumber Null
    {
        // Это тот же Null,
        // что видели раньше во встроенных типах:
        // SqlString.Null, SqlInt32.Null
        get
        {            
            PhoneNumber phone = new PhoneNumber();
            phone._number = string.Empty;
            return phone;
        }
    }

    // Parse() вызывается, когда присваиваем строку:
    // DECLARE @phone PhoneNumber
    // SET @phone = '9091234567'
    public static PhoneNumber Parse(SqlString s)
    {
        if (s.IsNull)
            return PhoneNumber.Null;

        PhoneNumber phone = new PhoneNumber();
        phone.Number = s;

        return phone;
    }

    // IBinarySerialize
    public void Read(BinaryReader r)
    {
        _number = r.ReadString();
    }

    // IBinarySerialize
    public void Write(BinaryWriter w)
    {
        w.Write(_number);
    }
}