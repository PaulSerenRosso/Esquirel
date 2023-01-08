using System.Collections;
using System.Collections.Generic;
using Entities;
using Entities.Capacities;
using UnityEngine;

public class ActiveAttackWithColliderWithPrevisualisableCapacity : ActiveAttackWithColliderCapacity, IPrevisualisable
{
    private bool canDraw = true;
    private bool isDrawing = false;
    protected ActiveAttackCapacityPrevizualisable previsualisableObject;
    public virtual void EnableDrawing()
    {
        isDrawing = true;
        previsualisableObject.gameObject.SetActive(true);
    }
    
    public virtual void DisableDrawing()
    {
        isDrawing = false;
        previsualisableObject.gameObject.SetActive(false);
    }

    public bool GetIsDrawing()
    {
        return isDrawing;
    }

    public void SetIsDrawing(bool value)
    {
        isDrawing = value;
    }

    public bool GetCanDraw()
    {
        if (champion.currentCapacityUsed != null) return false;
        return canDraw;
    }

    public void SetCanDraw(bool value)
    {
        canDraw = value;
    }
    public virtual bool TryCastWithPrevisualisableData(int[] targetsEntityIndexes, Vector3[] targetPositions,
        params object[] previsualisableParameters)
    {
         
        return TryCast(targetsEntityIndexes, targetPositions);
    }

    public virtual object[] GetPrevisualisableData()
    {
        return null;
    }

    public bool GetCanSkipDrawing()
    {
        return false;
    }

    public void SetCanSkipDrawing(bool value)
    {
        throw new System.NotImplementedException();
    }

    public override void SetUpActiveCapacity(byte soIndex, Entity caster)
    {
        base.SetUpActiveCapacity(soIndex, caster);
        if (champion.photonView.IsMine)
        {
            ActiveAttackWithColliderWithPrevisualisableSo attackWithColliderWithPrevisualisableSo = (ActiveAttackWithColliderWithPrevisualisableSo)so; 
            previsualisableObject =
                Object.Instantiate(attackWithColliderWithPrevisualisableSo.previsualisablePrefab, champion.transform)
                    .GetComponent<ActiveAttackCapacityPrevizualisable>();
            previsualisableObject.gameObject.SetActive(false);
            previsualisableObject.UpdatePrevisualisation(this);
            champion.OnSetCooldownFeedback += DisableCanDraw;
        }
    }
    void DisableCanDraw(byte index, bool value)
    {
        if (index == indexOfSOInCollection)
            canDraw = true;
    }
}
