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
            InitiateFXTimer();
            champion.SetCanMoveRPC(false);
            return true;
        }

        return false;
    }

    protected override void InitiateFXTimer()
    {
        base.InitiateFXTimer();

    }
    
    protected override void CancelDamagePrefab()
    {
        base.CancelDamagePrefab();
        champion.SetCanMoveRPC(true);
    }
}

}
