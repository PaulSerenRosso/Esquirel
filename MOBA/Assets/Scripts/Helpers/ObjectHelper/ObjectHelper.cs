using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class ObjectHelper 
{
    public static void SetGlobalScale(this Transform _transform, Vector3 newScale)
    {
        Transform parent = _transform.parent;
        _transform.parent = null;
        _transform.localScale = newScale;
        _transform.parent = parent;
    }

    public static void SetGlobalScale(this Transform _transform, Coordinate[] _coordinates)
    {
        Transform parent = _transform.parent;
        _transform.parent = null;
        Vector3 transformScale = _transform.localScale;
        for (int i = 0; i < _coordinates.Length; i++)
        {
        switch (_coordinates[i].Type)
        {
            case CoordinateType.X:
            {
                transformScale.x = _coordinates[i].Value;
                break;
            }
            case CoordinateType.Y:
            {
                transformScale.y = _coordinates[i].Value;
                break;
            }
            case CoordinateType.Z:
            {
                transformScale.z = _coordinates[i].Value;
                break;
            }
        }
        }
        _transform.localScale = transformScale;
        _transform.parent = parent;
    }
    
    public static void SetGlobalRotation(this Transform _transform, Coordinate[] _coordinates)
    {
        Vector3 transformRotation = _transform.rotation.eulerAngles;
        for (int i = 0; i < _coordinates.Length; i++)
        {
            switch (_coordinates[i].Type)
            {
                case CoordinateType.X:
                {
                    transformRotation.x = _coordinates[i].Value;
                    break;
                }
                case CoordinateType.Y:
                {
                    transformRotation.y = _coordinates[i].Value;
                    break;
                }
                case CoordinateType.Z:
                {
                    transformRotation.z = _coordinates[i].Value;
                    break;
                }
            }
        }
        _transform.rotation = Quaternion.Euler(transformRotation);
    }
    
    public static Vector3 ConvertTo3dSpace(this Vector2 _position2d, CoordinateType _xConverter , CoordinateType _yConverter, Vector3 _offset)
    {
        Coordinate[] coordinatesToConvert = new[] { new Coordinate(_xConverter,_position2d.x), new Coordinate(_yConverter, _position2d.y)};
        
        Vector3 result = Vector3.zero;
        for (int i = 0; i < coordinatesToConvert.Length; i++)
        {
            switch (coordinatesToConvert[i].Type)
            {
                case CoordinateType.X :
                {
                    result.x = coordinatesToConvert[i].Value;
                 break;   
                }
                case CoordinateType.Y : 
                {
                    result.y = coordinatesToConvert[i].Value;
                    break; 
                }
                case CoordinateType.Z : 
                {
                    result.z = coordinatesToConvert[i].Value;
                    break; 
                }
            }
        }
        result += _offset;
        return result;
    }
    
    public static void ResetTransform(this Transform _t) // Reset un transform
    {
        _t.position = Vector3.zero;
        _t.rotation = Quaternion.identity;
        _t.localScale = Vector3.one;
    }
}
