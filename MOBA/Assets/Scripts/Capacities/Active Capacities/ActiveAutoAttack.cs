using Entities;
using Entities.Capacities;
using Entities.Champion;
using GameStates;
using UnityEngine;

public class ActiveAutoAttack : ActiveCapacity, IAimable
{
    private ActiveAutoAttackSO activeAutoAttackSO;

    public float range;
    public float rangeSqrt;
    //delay 
    // 


    public override bool TryCast(int casterIndex, int[] targetsEntityIndexes, Vector3[] targetPositions)
    {
        if (!onCooldown)
        {
            
        InitiateCooldown();
        var entity = EntityCollectionManager.GetEntityByIndex(targetsEntityIndexes[0]);
        IActiveLifeable lifeable = (IActiveLifeable)entity;
        //attendre un petit peut 
        lifeable.DecreaseCurrentHpRPC(activeAutoAttackSO.damage);
        return true;
        }
        return false; 
    }

    public override void PlayFeedback(int entityIndex, int[] targets, Vector3[] position)
    {
        Debug.Log("AutoAtk Feedback");
    }

    public override void SetUpActiveCapacity(byte soIndex, Entity caster)
    {
        base.SetUpActiveCapacity(soIndex, caster);

        activeAutoAttackSO = (ActiveAutoAttackSO)AssociatedActiveCapacitySO();
        range = activeAutoAttackSO.maxRange;
        rangeSqrt = range * range;
        Champion champion =(Champion) caster;
          //   cooldownIsReadyEvent += champion.RequestToChangeCooldownIsReady;
    }

    public float GetMaxRange()
    {
        return range;
    }

    public float GetSqrtMaxRange()
    {
        return rangeSqrt;
    }

    protected virtual void InitiateCooldown()
    {
      
        GameStateMachine.Instance.OnTick += CooldownTimer;
    }

    /// <summary>
    /// Method which update the timer.
    /// </summary>
    protected virtual void ActiveCollision()
    {
        
    }
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