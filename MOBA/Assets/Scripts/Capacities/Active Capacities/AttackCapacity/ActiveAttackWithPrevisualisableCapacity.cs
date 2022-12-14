using System.Collections;
using System.Collections.Generic;
using Entities;
using Entities.Capacities;
using UnityEngine;

public class ActiveAttackWithPrevisualisableCapacity : ActiveAttackCapacity, IPrevisualisable
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

    public override void SetUpActiveCapacity(byte soIndex, Entity caster)
    {
        base.SetUpActiveCapacity(soIndex, caster);
        if (champion.photonView.IsMine)
        {
            ActiveAttackWithPrevisualisableSO attackWithPrevisualisableSo = (ActiveAttackWithPrevisualisableSO)so; 
            previsualisableObject =
                Object.Instantiate(attackWithPrevisualisableSo.previsualisablePrefab, champion.transform)
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
