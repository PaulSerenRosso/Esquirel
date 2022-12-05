using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum CoordinateType
{
X,Y,Z
}

public class Coordinate
{
    public Coordinate(CoordinateType _type, float _value)
    {
        Type = _type;
        Value = _value;
    }
    public CoordinateType Type;
    public float Value;
}
