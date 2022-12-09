using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AttackPrevizualisable: MonoBehaviour
{
    [SerializeField] private GameObject previsualisationRect;

    public virtual void UpdatePrevisualisation(float width, float height)
    {
        previsualisationRect.transform.SetGlobalScale(new Coordinate[]
            { new Coordinate(CoordinateType.X, height), new Coordinate(CoordinateType.Z, width)});
    }
}