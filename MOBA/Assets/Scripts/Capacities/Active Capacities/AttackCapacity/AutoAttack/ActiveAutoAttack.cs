using Entities;
using Entities.Capacities;
using Entities.Champion;
using Entities.FogOfWar;
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

    private IActiveLifeable lifeableTarget;
    private Entity targetEntity;

    public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions){
    
        if(champion.currentCapacityUsed == null)
    {
        if (base.TryCast(targetsEntityIndexes, targetPositions))
        {
            InitiateCooldown();
            damageTimer.InitiateTimerEvent -= TryMakeDamageToTargetEntity;
            targetEntity = EntityCollectionManager.GetEntityByIndex(targetsEntityIndexes[0]);
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
    }

    return false;
    }

    protected override void InitFX(int[] targetsEntityIndexes, Vector3[] targetPositions)
    {
        directionAttack = (targetPositions[0] - caster.transform.position).normalized;
        fxInfo.fxRotation =
            Quaternion.LookRotation((targetPositions[0] - caster.transform.position).normalized, Vector3.up);
        base.InitFX(targetsEntityIndexes, targetPositions);
    }

    private void TryMakeDamageToTargetEntity()
    {
        if ((champion.transform.position - targetEntity.transform.position).sqrMagnitude < sqrRangeForDamage)
        {
            targetEntityIsLifeable = true;
            impactFxTimerInfo.fxPos =targetEntity.entityCapacityCollider.GetCollider.ClosestPoint(champion.transform.position);
            impactFxTimerInfo.fxPos.y = FogOfWarManager.Instance.startYPositionRay;
            impactFxTimerInfo.fxRotation =
                Quaternion.LookRotation((impactFxTimerInfo.fxPos-champion.transform.position).normalized, Vector3.up);
            impactFxTimer.InitiateTimer();
            lifeableTarget.DecreaseCurrentHpRPC(damage);
        }
 
    }

    protected override void EndAttackTimer()
    {
         champion.CancelAutoAttackRPC();
        damageTimer.CancelTimer();
    }

    public override void CancelCapacity()
    {
        base.CancelCapacity();
        
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
        if (PhotonNetwork.IsMasterClient)
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