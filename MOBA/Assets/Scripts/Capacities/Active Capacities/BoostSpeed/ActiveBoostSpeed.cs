using System.Collections;
using System.Collections.Generic;
using Entities;
using Entities.Capacities;
using Entities.Champion;
using UnityEngine;

namespace Entities.Capacities
{
public class ActiveBoostSpeed : ActiveCapacity
{
    private ActiveBoostSpeedSO activeBoostSpeedSo;
    private Champion.Champion champion;
    public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
    {
        if (!onCooldown)
        {
            InitiateCooldown();
            caster.RequestAddPassiveCapacity(activeBoostSpeedSo.passiveSpeedSo.indexInCollection);
            champion.RequestToSetOnCooldownCapacity(indexOfSOInCollection, true);
            return true;
        }

        return false;
    }

    public override void EndCooldown()
    {
        base.EndCooldown();
        champion.RequestToSetOnCooldownCapacity(indexOfSOInCollection, false);
    }

    public override void CancelCapacity()
    {
        
    }

    public override void SetUpActiveCapacity(byte soIndex, Entity caster)
    {
        base.SetUpActiveCapacity(soIndex, caster);
        activeBoostSpeedSo = (ActiveBoostSpeedSO) CapacitySOCollectionManager.GetActiveCapacitySOByIndex(indexOfSOInCollection);
         champion =(Champion.Champion) caster;
    }
}
}
