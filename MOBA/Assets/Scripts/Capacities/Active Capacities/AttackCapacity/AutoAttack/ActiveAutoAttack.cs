using Entities;
using Entities.Capacities;
using Entities.Champion;
using GameStates;
using Photon.Pun;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Assertions.Must;

public class ActiveAutoAttack : ActiveAttackCapacity, IAimable
{
    private ActiveAutoAttackSO activeAutoAttackSO;

    public float sqrRangeForDamage;
    public float range;
    public float rangeSqr;
    private bool targetEntityIsLifeable;
    private Vector3 entityTargetPos;
    private IActiveLifeable lifeableTarget;

    public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
    {
        if (base.TryCast(targetsEntityIndexes, targetPositions))
        {
            rotationFx =
                Quaternion.LookRotation((targetPositions[0] - caster.transform.position).normalized, Vector3.up);
            InitiateCooldown();
            InitiateFXTimer();
            entityTargetPos = targetPositions[0];
            damageTimer.InitiateTimerEvent -= TryMakeDamageToTargetEntity;
            Entity targetEntity = EntityCollectionManager.GetEntityByIndex(targetsEntityIndexes[0]);
            if (targetEntity is IActiveLifeable lifeable)
            {
                lifeableTarget = lifeable;
                targetEntityIsLifeable = true;
                damageTimer.InitiateTimerEvent += TryMakeDamageToTargetEntity;
            }
            else
            {
                targetEntityIsLifeable = false;
            }

            return true;
        }

        return false;
    }


    private void TryMakeDamageToTargetEntity()
    {
        if ((champion.transform.position - entityTargetPos).sqrMagnitude < sqrRangeForDamage)
        {
            targetEntityIsLifeable = true;
            lifeableTarget.DecreaseCurrentHpRPC(activeAutoAttackSO.damage);
        }

        damageTimer.CancelTimer();
    }

    private void CancelDamage()
    {
        champion.SetCanMoveRPC(true);
    }
    public override void SyncCapacity(int[] targetsEntityIndexes, Vector3[] targetPositions,
        params object[] customParameters)
    {
        champion.RotateMeshChampionRPC((targetPositions[0] - caster.transform.position).normalized);

        champion.SyncSetCanMoveRPC(false);
    }

    public override void SetUpActiveCapacity(byte soIndex, Entity caster)
    {
        base.SetUpActiveCapacity(soIndex, caster);
        activeAutoAttackSO = (ActiveAutoAttackSO)CapacitySOCollectionManager.GetActiveCapacitySOByIndex(soIndex);
        range = activeAutoAttackSO.maxRange;
        sqrRangeForDamage = activeAutoAttackSO.rangeForDamage * activeAutoAttackSO.rangeForDamage;
        rangeSqr = range * range;
        if(PhotonNetwork.IsMasterClient)
        damageTimer.CancelTimerEvent += CancelDamage;
    }


    public float GetMaxRange()
    {
        return range;
    }

    public float GetSqrMaxRange()
    {
        return rangeSqr;
    }

    /// <summary>
    /// Method which update the timer.
    /// </summary>
    public bool TryAim(int casterIndex, int targetsEntityIndex, Vector3 targetPosition)
    {
        if (EntityCollectionManager.GetEntityByIndex(casterIndex).team !=
            EntityCollectionManager.GetEntityByIndex(targetsEntityIndex).team)
            return true;

        return false;
    }
}