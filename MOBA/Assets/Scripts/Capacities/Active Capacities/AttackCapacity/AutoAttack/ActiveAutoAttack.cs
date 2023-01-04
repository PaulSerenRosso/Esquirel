using Entities;
using Entities.Capacities;
using Entities.Champion;
using GameStates;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Assertions.Must;

public class ActiveAutoAttack : ActiveCapacity, IAimable
{
    private ActiveAutoAttackSO activeAutoAttackSO;
    private ActiveCapacityAnimationLauncher activeCapacityAnimationLauncher;
    public Champion champion;
    public float range;
    public float rangeSqrt;
    protected Quaternion rotationFx;
    
    public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
    {
        if (onCooldown) return false;
        activeCapacityAnimationLauncher.InitiateAnimationTimer();
        InitiateCooldown();
        activeCapacityAnimationLauncher.InitiateAnimationTimer();
        rotationFx = Quaternion.LookRotation((targetPositions[0] - caster.transform.position).normalized, Vector3.up);
        InitiateFXTimer();
        
        return true;
    }


    public override void CancelCapacity()
    {
        activeCapacityAnimationLauncher.CancelAnimationTimer();
        CancelFXTimer();
    }

    public override void InitiateCooldown()
    {
        base.InitiateCooldown();
        if (champion.activeCapacities.Contains(this))
            champion.RequestToSetOnCooldownCapacity(indexOfSOInCollection, true);
    }

    public override void EndCooldown()
    {
        champion.RequestToSetOnCooldownCapacity(indexOfSOInCollection, false);
        base.EndCooldown();
    }

    protected override void InitiateFXTimer()
    {
        base.InitiateFXTimer();
        fxObject = PoolNetworkManager.Instance.PoolInstantiate(activeAutoAttackSO.fxPrefab, champion.transform.position, rotationFx);
        ActiveAttackCapacityFX attackCapacityFX = (ActiveAttackCapacityFX)fxObject;
        attackCapacityFX.RequestInitCapacityFX(caster.entityIndex, (byte)champion.activeCapacities.IndexOf(this));
    }


    public override void SetUpActiveCapacity(byte soIndex, Entity caster)
    {
        base.SetUpActiveCapacity(soIndex, caster);
        activeAutoAttackSO = (ActiveAutoAttackSO)CapacitySOCollectionManager.GetActiveCapacitySOByIndex(soIndex);
        champion = (Champion)caster;
        activeCapacityAnimationLauncher = new ActiveCapacityAnimationLauncher();
        activeCapacityAnimationLauncher.Setup(activeAutoAttackSO.activeCapacityAnimationLauncherInfo, champion);
        range = activeAutoAttackSO.maxRange;
        rangeSqrt = range * range;
    }


    public float GetMaxRange()
    {
        return range;
    }

    public float GetSqrtMaxRange()
    {
        return rangeSqrt;
    }

    public override void SyncCapacity(int[] targetsEntityIndexes, Vector3[] targetPositions,
        params object[] customParameters)
    {
        champion.RotateMeshChampionRPC((targetPositions[0] - caster.transform.position).normalized);
        champion.SyncSetCanMoveRPC(false);
    }

    /// <summary>
    /// Method which update the timer.
    /// </summary>
    public bool TryAim(int casterIndex, int targetsEntityIndex, Vector3 targetPosition)
    {
        if (EntityCollectionManager.GetEntityByIndex(casterIndex).team !=
            EntityCollectionManager.GetEntityByIndex(targetsEntityIndex).team)
        {
            return true;
        }
        return false;
    }
}