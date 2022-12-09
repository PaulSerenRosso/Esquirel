using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using UnityEngine;

namespace Entities.Capacities
{
    
public class AttackCapacity : ActiveCapacity, IPrevisualisable
{
    public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
    {
        throw new System.NotImplementedException();
    }

    public override void CancelCapacity()
    {
        throw new System.NotImplementedException();
    }

    public void EnableDrawing()
    {
        throw new System.NotImplementedException();
    }

    public void DisableDrawing()
    {
        throw new System.NotImplementedException();
    }

    public bool GetIsDrawing()
    {
        throw new System.NotImplementedException();
    }

    public void SetIsDrawing(bool value)
    {
        throw new System.NotImplementedException();
    }

    public bool GetCanDraw()
    {
        throw new System.NotImplementedException();
    }

    public void SetCanDraw(bool value)
    {
        throw new System.NotImplementedException();
    }

    public bool TryCastWithPrevisualisableData(int[] targetsEntityIndexes, Vector3[] targetPositions,
        params object[] previsualisableData)
    {
        throw new System.NotImplementedException();
    }

    public object[] GetPrevisualisableData()
    {
        throw new System.NotImplementedException();
    }
}
}
