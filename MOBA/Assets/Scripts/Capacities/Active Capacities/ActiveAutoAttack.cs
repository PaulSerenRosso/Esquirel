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
        animationTimer = activeAutoAttackSO.animationTime;
        caster.RequestChangeBoolParameterAnimator("autoAttack", true);
        GameStateMachine.Instance.OnTick += TickAnimationTimer;
    }


    void InitiateBeginDamageTimer()
    {
        beginDamageTimer = activeAutoAttackSO.damageBeginTime;
        GameStateMachine.Instance.OnTick += TickBeginDamageTimer;
    }


    void InitiateDamageTimer()
    {
        damageTimer = activeAutoAttackSO.damageTime;
        DamageObject = PoolLocalManager.Instance.PoolInstantiate(activeAutoAttackSO.damagePrefab,
            caster.transform.position, caster.rotateParent.rotation);
        var activeCapacityCollider = DamageObject.transform.GetChild(0).GetComponent<ActiveCapacityCollider>();
        activeCapacityCollider.InitCapacityCollider(this);

        GameStateMachine.Instance.OnTick += TickDamageTimer;
    }

    void TickAnimationTimer()
    {
        animationTimer -= 1.0 / GameStateMachine.Instance.tickRate;

        if (animationTimer <= 0)
        {
            CancelAnimationTimer();
        }
    }

    private void CancelAnimationTimer()
    {
        caster.RequestChangeBoolParameterAnimator("autoAttack", false);
        GameStateMachine.Instance.OnTick -= TickAnimationTimer;
    }


    void TickBeginDamageTimer()
    {
        beginDamageTimer -= 1.0 / GameStateMachine.Instance.tickRate;

        if (beginDamageTimer <= 0)
        {
            CancelBeginDamageTimer();
        }
    }

    private void CancelBeginDamageTimer()
    {
        InitiateDamageTimer();
        GameStateMachine.Instance.OnTick -= TickBeginDamageTimer;
    }

    void TickDamageTimer()
    {
        damageTimer -= 1.0 / GameStateMachine.Instance.tickRate;

        if (damageTimer <= 0)
        {
            CancelDamageTimer();
        }
    }

    private void CancelDamageTimer()
    {
        if (DamageObject != null)
        {
            PoolLocalManager.Instance.EnqueuePool(activeAutoAttackSO.damagePrefab, DamageObject);
            DamageObject = null;
        }
        GameStateMachine.Instance.OnTick -= TickDamageTimer;
        caster.RequestCurrentResetCapacityUsed();
    }


    protected override void InitiateFXTimer()
    {
        base.InitiateFXTimer();
        fxObject = PoolNetworkManager.Instance.PoolInstantiate(activeAutoAttackSO.fxPrefab, caster.transform.position,
            caster.rotateParent.rotation);
        fxObject.RequestChangeTeam(caster.team);
       
    }

    public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
    {
        if (!onCooldown)
        {
            caster.rotateParent.forward = (
                EntityCollectionManager.GetEntityByIndex(targetsEntityIndexes[0]).transform
                                               .position-caster.transform.position).normalized;
            InitiateCooldown();
            InitiateAnimationTimer();
            InitiateBeginDamageTimer();
            InitiateFXTimer();
            return true;
        }

        return false;
    }




    public override void CancelCapacity()
    {
        GameStateMachine.Instance.OnTick -= TickBeginDamageTimer;
        CancelAnimationTimer();
        CancelDamageTimer();
        CancelFXTimer();
        caster.RequestCurrentResetCapacityUsed();
    }
    

    public override void SetUpActiveCapacity(byte soIndex, Entity caster)
    {
        base.SetUpActiveCapacity(soIndex, caster);

        activeAutoAttackSO = (ActiveAutoAttackSO) AssociatedActiveCapacitySO();
        range = activeAutoAttackSO.maxRange;
        rangeSqrt = range * range;
        this.caster = (Champion) caster;

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