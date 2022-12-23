using Entities;
using Entities.Capacities;
using Entities.Champion;
using GameStates;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Assertions.Must;

public class ActiveAutoAttack : ActiveAttackCapacity, IAimable
{
    private ActiveAutoAttackSO activeAutoAttackSO;


    private ActiveCapacityAnimationLauncher activeCapacityAnimationLauncher;

    public float range;
    public float rangeSqrt;

    public override void InitiateCooldown()
    {
        base.InitiateCooldown();
        Debug.Log("bonsoir je suis tout le temps lu aussi");
    }

    public override void EndCooldown()
    {
        Debug.Log("bonsoir je suis tout le temps lu");
        base.EndCooldown();
    }


    protected override void CancelDamagePrefab()
    {
        base.CancelDamagePrefab();
        champion.SetCanMoveRPC(true);
        champion.RequestCurrentResetCapacityUsed();
    }

    public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
    {
        if (base.TryCast(targetsEntityIndexes, targetPositions))
        {
            InitiateCooldown();
            rotationFx = Quaternion.LookRotation((targetPositions[0] - caster.transform.position).normalized, Vector3.up);
            InitiateFXTimer();
        }

        return true;
    }

    public override void CancelCapacity()
    {
        base.CancelCapacity();
        champion.RequestCurrentResetCapacityUsed();
    }


    public override void SetUpActiveCapacity(byte soIndex, Entity caster)
    {
        base.SetUpActiveCapacity(soIndex, caster);
        activeAutoAttackSO = (ActiveAutoAttackSO) AssociatedActiveCapacitySO();
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

    public override void SyncCapacity(int[] targetsEntityIndexes, Vector3[] targetPositions, params object[] customParameters)
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