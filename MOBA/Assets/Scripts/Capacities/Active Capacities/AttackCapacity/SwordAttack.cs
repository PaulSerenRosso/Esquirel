using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Entities.Capacities
{
public class SwordAttack : ActiveAttackRectCapacity
{
    public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
    {
        if (base.TryCast(targetsEntityIndexes, targetPositions))
        {
            InitiateCooldown();
            return true;
        }
        return false;
    }

    public override void SyncCapacity(int[] targetsEntityIndexes, Vector3[] targetPositions, params object[] customParameters)
    {
        base.SyncCapacity(targetsEntityIndexes, targetPositions, customParameters);
        champion.SyncSetCanMoveRPC(false);
    }
    
    protected override void CancelDamagePrefab()
    {
        base.CancelDamagePrefab();
        champion.SetCanMoveRPC(true);
    }
}

}
