using Entities;
using Entities.Capacities;
using Entities.Champion;
using GameStates;
using Unity.Mathematics;
using UnityEngine;

public class ActiveAutoAttack : ActiveCapacity, IAimable
{
    private ActiveAutoAttackSO activeAutoAttackSO;

    public float range;
    public float rangeSqrt;

    public float timeFactor = 1;
    private double animationTimer;
    private double damageTimer;
    
    private GameObject DamageObject;
    private double beginDamageTimer;

    //delay 
    // 
    private Champion caster;

    void InitiateAnimationTimer()
    {
        animationTimer = 0;
        GameStateMachine.Instance.OnTick += TickAnimationTimer;
    }



    void InitiateBeginDamageTimer()
    {
        beginDamageTimer = 0;
        GameStateMachine.Instance.OnTick += TickBeginDamageTimer;
    }


    void InitiateDamageTimer()
    {
        damageTimer = 0;
        DamageObject = PoolLocalManager.Instance.PoolInstantiate(activeAutoAttackSO.damagePrefab,
            caster.transform.position, caster.transform.rotation, caster.transform);
        var activeCapacityCollider = DamageObject.transform.GetChild(0).GetComponent<ActiveCapacityCollider>();
        activeCapacityCollider.InitCapacityCollider(this);
        
        GameStateMachine.Instance.OnTick += TickDamageTimer;
    }

    void TickAnimationTimer()
    {
        animationTimer -= 1.0 / GameStateMachine.Instance.tickRate;

        if (animationTimer <= 0)
        {
            caster.animator.SetBool("AutoAttack", false);
            GameStateMachine.Instance.OnTick -= TickAnimationTimer;
        }
    }


    void TickBeginDamageTimer()
    {
        beginDamageTimer -= 1.0 / GameStateMachine.Instance.tickRate;

        if (beginDamageTimer <= 0)
        {
            InitiateDamageTimer();
            GameStateMachine.Instance.OnTick -= TickBeginDamageTimer;
        }
    }

    void TickDamageTimer()
    {
        damageTimer -= 1.0 / GameStateMachine.Instance.tickRate;

        if (damageTimer <= 0)
        {
            PoolLocalManager.Instance.EnqueuePool(activeAutoAttackSO.damagePrefab, DamageObject);
            GameStateMachine.Instance.OnTick -= TickDamageTimer;
        }
    }


    protected override void InitiateFXTimer()
    {
        base.InitiateFXTimer();
        fxObject = PoolNetworkManager.Instance.PoolInstantiate(activeAutoAttackSO.fxPrefab, caster.transform.position,
            caster.transform.rotation, caster.transform);
    }

    public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
    {
        if (!onCooldown)
        {
            InitiateCooldown();
            InitiateAnimationTimer();
            InitiateBeginDamageTimer();
            InitiateFXTimer();
            caster.animator.SetBool("AutoAttack", true);
           
            return true;
        }

        return false;
    }

    public override void PlayFeedback(int[] targets, Vector3[] position)
    {
        Debug.Log(activeAutoAttackSO.fxPrefab);
        Debug.Log(caster);
      
      
    }


    public override void CancelCapacity()
    {
    GameStateMachine.Instance.OnTick -= TickDamageTimer;
    GameStateMachine.Instance.OnTick -= TickAnimationTimer;
    GameStateMachine.Instance.OnTick -= TickFxTimer;
    GameStateMachine.Instance.OnTick -= TickBeginDamageTimer;
    }

    public override void SetUpActiveCapacity(byte soIndex, Entity caster)
    {
        base.SetUpActiveCapacity(soIndex, caster);

        activeAutoAttackSO = (ActiveAutoAttackSO)AssociatedActiveCapacitySO();
        Debug.Log(activeAutoAttackSO);
        range = activeAutoAttackSO.maxRange;
        rangeSqrt = range * range;
        this.caster = (Champion)caster;

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