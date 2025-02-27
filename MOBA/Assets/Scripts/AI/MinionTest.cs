using System;
using System.Collections;
using System.Collections.Generic;
using Entities;
using Entities.Capacities;
using Entities.FogOfWar;
using Photon.Pun;
using UnityEngine;
using UnityEngine.AI;

public partial class MinionTest : Entity, IMoveable, IAttackable, IActiveLifeable
{
    #region MinionVariables
    
    public NavMeshAgent myAgent;
    private MinionController myController;
    
    [Header("Pathfinding")] 
    public List<Transform> myWaypoints = new List<Transform>();
    public List<Building> TowersList = new List<Building>();
    public int wayPointIndex;
    public int towerIndex;

    public enum MinionAggroState { None, Tower, Minion, Champion };
    public enum MinionAggroPreferences { Tower, Minion, Champion }
    [Header ("Attack Logic")]
    public MinionAggroState currentAggroState = MinionAggroState.None;
    public MinionAggroPreferences whoAggro = MinionAggroPreferences.Tower;
    public LayerMask enemyMinionMask;
    public GameObject currentAttackTarget;
    public List<GameObject> whoIsAttackingMe = new List<GameObject>();
    public bool attackCycle;

    [Header("Stats")]
    public float currentHealth;
    public float attackDamage;
    public float attackSpeed;
    [Range(2, 8)] public float attackRange;
    public float delayBeforeAttack;
    public float maxHealth;
    #endregion

    protected override void OnStart()
    {
        base.OnStart();
        myAgent = GetComponent<NavMeshAgent>();
        myController = GetComponent<MinionController>();
        currentHealth = maxHealth;
        Debug.Log("OnStart ? " + gameObject.name);
    }
    
    //------ State Methods

    public void IdleState()
    {
        myAgent.isStopped = true;
        CheckObjectives();
    }

    public void WalkingState()
    {
        CheckMyWayPoints();
        CheckObjectives();
        //CheckEnemiesMinion();
    }

    public void LookingForPathingState()
    {
        myAgent.SetDestination(myWaypoints[wayPointIndex].position);
        myController.currentState = MinionController.MinionState.Walking;
    }

    public void AttackingState()
    {
        if (TowersList[towerIndex].isAlive)
        {
            var q = Quaternion.LookRotation(currentAttackTarget.transform.position - transform.position);
            transform.rotation = Quaternion.RotateTowards(transform.rotation, q, 50f * Time.deltaTime);

            if (attackCycle == false)
            {
                StartCoroutine(AttackLogic());
            }
        }
        else
        {
            myController.currentState = MinionController.MinionState.LookingForPathing;
            currentAggroState = MinionAggroState.None;
            currentAttackTarget = null;
            towerIndex++;
        }
    }
    
    //------Others Methods
    private void CheckMyWayPoints()
    {
        if (Vector3.Distance(transform.position, myWaypoints[wayPointIndex].transform.position) <= myAgent.stoppingDistance /* Definir range de detection des waypoints en variable si besoin*/) 
        {
            if (wayPointIndex < myWaypoints.Count - 1)
            {
                wayPointIndex++;
                myAgent.SetDestination(myWaypoints[wayPointIndex].position);
            }
            else
            {
                myController.currentState = MinionController.MinionState.Idle;
            }
        }
    }
    
    private void CheckObjectives()
    {
        if (!TowersList[towerIndex].isAlive)
            return;
        
        if (Vector3.Distance(transform.position, TowersList[towerIndex].transform.position) > attackRange)
        {
            myController.currentState = MinionController.MinionState.Walking;
        }
        else
        {
            myAgent.SetDestination(transform.position);
            myController.currentState = MinionController.MinionState.Attacking;
            currentAggroState = MinionAggroState.Tower;
            currentAttackTarget = TowersList[towerIndex].gameObject;
        }
    }
    
    private IEnumerator AttackLogic()
    {
        if (TowersList[towerIndex].isAlive)
        {
            attackCycle = true;
            AttackTarget(currentAttackTarget);
            yield return new WaitForSeconds(attackSpeed);
            attackCycle = false; 
        }
    }
    
    private void AttackTarget(GameObject target) // Attaque de l'entité référencée 
    {
        Debug.Log("Attack by " + gameObject.name);
        int[] targetEntity = new[] { target.GetComponent<Entity>().entityIndex };
        
        AttackRPC(2, targetEntity, Array.Empty<Vector3>());
    }
    
    [PunRPC]
    public void AttackRPC(byte capacityIndex, int[] targetedEntities, Vector3[] targetedPositions)
    {
        var attackCapacity = CapacitySOCollectionManager.CreateActiveCapacity(capacityIndex,this);

        if (!attackCapacity.TryCast( targetedEntities, targetedPositions)) return;
            
        OnAttack?.Invoke(capacityIndex,targetedEntities,targetedPositions);
        photonView.RPC("SyncAttackRPC",RpcTarget.All,capacityIndex,targetedEntities,targetedPositions);
    }

    public bool GetCanDecreaseCurrentHp()
    {
        throw new NotImplementedException();
    }

    public void RequestSetCanDecreaseCurrentHp(bool value)
    {
        throw new NotImplementedException();
    }

    public void SyncSetCanDecreaseCurrentHpRPC(bool value)
    {
        throw new NotImplementedException();
    }
}

public partial class MinionTest : IDeadable
{
    public event GlobalDelegates.ThirdParameterDelegate<byte , int[] , Vector3[]> OnAttack;
    public event GlobalDelegates.ThirdParameterDelegate<byte , int[] , Vector3[]> OnAttackFeedback;

    public bool CanAttack()
    {
        throw new System.NotImplementedException();
    }

    public void RequestSetCanAttack(bool value)
    {
        throw new System.NotImplementedException();
    }

    public void SetCanAttackRPC(bool value)
    {
        throw new System.NotImplementedException();
    }

    public void SyncSetCanAttackRPC(bool value)
    {
        throw new System.NotImplementedException();
    }

    public event GlobalDelegates.OneParameterDelegate<bool> OnSetCanAttack;
    public event GlobalDelegates.OneParameterDelegate<bool> OnSetCanAttackFeedback;
    public float GetAttackDamage()
    {
        throw new System.NotImplementedException();
    }

    public void RequestSetAttackDamage(float value)
    {
        throw new System.NotImplementedException();
    }

    public void SyncSetAttackDamageRPC(float value)
    {
        throw new System.NotImplementedException();
    }

    public void SetAttackDamageRPC(float value)
    {
        throw new System.NotImplementedException();
    }

    public event GlobalDelegates.OneParameterDelegate<float> OnSetAttackDamage;
    public event GlobalDelegates.OneParameterDelegate<float> OnSetAttackDamageFeedback;

    public void RequestAttack(byte capacityIndex, int[] targetedEntities, Vector3[] targetedPositions)
    {
        throw new System.NotImplementedException();
    }

    [PunRPC]
    public void SyncAttackRPC(byte capacityIndex, int[] targetedEntities, Vector3[] targetedPositions)
    {
        var attackCapacity = CapacitySOCollectionManager.CreateActiveCapacity(capacityIndex,this);
        OnAttackFeedback?.Invoke(capacityIndex,targetedEntities,targetedPositions);
    }
    
    //------
    
    public override void OnInstantiated()
    {
        base.OnInstantiated();
    }

    public override void OnInstantiatedFeedback()
    {
    }

    public bool CanMove()
    {
        throw new System.NotImplementedException();
    }

    public float GetReferenceMoveSpeed()
    {
        throw new System.NotImplementedException();
    }

    public float GetCurrentMoveSpeed()
    {
        throw new System.NotImplementedException();
    }

    public void RequestSetCanMove(bool value)
    {
        throw new System.NotImplementedException();
    }

    public void SyncSetCanMoveRPC(bool value)
    {
        throw new System.NotImplementedException();
    }

    public void SetCanMoveRPC(bool value)
    {
        throw new System.NotImplementedException();
    }

    public event GlobalDelegates.OneParameterDelegate<bool> OnSetCanMove;
    public event GlobalDelegates.OneParameterDelegate<bool> OnSetCanMoveFeedback;
    public void RequestSetReferenceMoveSpeed(float value)
    {
        throw new System.NotImplementedException();
    }

    public void SyncSetReferenceMoveSpeedRPC(float value)
    {
        throw new System.NotImplementedException();
    }

    public void SetReferenceMoveSpeedRPC(float value)
    {
        throw new System.NotImplementedException();
    }

    public event GlobalDelegates.OneParameterDelegate<float> OnSetReferenceMoveSpeed;
    public event GlobalDelegates.OneParameterDelegate<float> OnSetReferenceMoveSpeedFeedback;
    public void RequestIncreaseReferenceMoveSpeed(float amount)
    {
        throw new System.NotImplementedException();
    }

    public void SyncIncreaseReferenceMoveSpeedRPC(float amount)
    {
        throw new System.NotImplementedException();
    }

    public void IncreaseReferenceMoveSpeedRPC(float amount)
    {
        throw new System.NotImplementedException();
    }

    public event GlobalDelegates.OneParameterDelegate<float> OnIncreaseReferenceMoveSpeed;
    public event GlobalDelegates.OneParameterDelegate<float> OnIncreaseReferenceMoveSpeedFeedback;
    public void RequestDecreaseReferenceMoveSpeed(float amount)
    {
        throw new System.NotImplementedException();
    }

    public void SyncDecreaseReferenceMoveSpeedRPC(float amount)
    {
        throw new System.NotImplementedException();
    }

    public void DecreaseReferenceMoveSpeedRPC(float amount)
    {
        throw new System.NotImplementedException();
    }

    public event GlobalDelegates.OneParameterDelegate<float> OnDecreaseReferenceMoveSpeed;
    public event GlobalDelegates.OneParameterDelegate<float> OnDecreaseReferenceMoveSpeedFeedback;
    public void RequestSetCurrentMoveSpeed(float value)
    {
        throw new System.NotImplementedException();
    }

    public void SyncSetCurrentMoveSpeedRPC(float value)
    {
        throw new System.NotImplementedException();
    }

    public void SetCurrentMoveSpeedRPC(float value)
    {
        throw new System.NotImplementedException();
    }

    public event GlobalDelegates.OneParameterDelegate<float> OnSetCurrentMoveSpeed;
    public event GlobalDelegates.OneParameterDelegate<float> OnSetCurrentMoveSpeedFeedback;
    public void RequestIncreaseCurrentMoveSpeed(float amount)
    {
        throw new System.NotImplementedException();
    }

    public void SyncIncreaseCurrentMoveSpeedRPC(float amount)
    {
        throw new System.NotImplementedException();
    }

    public void IncreaseCurrentMoveSpeedRPC(float amount)
    {
        throw new System.NotImplementedException();
    }

    public event GlobalDelegates.OneParameterDelegate<float> OnIncreaseCurrentMoveSpeed;
    public event GlobalDelegates.OneParameterDelegate<float> OnIncreaseCurrentMoveSpeedFeedback;
    public void RequestDecreaseCurrentMoveSpeed(float amount)
    {
        throw new System.NotImplementedException();
    }

    public void SyncDecreaseCurrentMoveSpeedRPC(float amount)
    {
        throw new System.NotImplementedException();
    }

    public void DecreaseCurrentMoveSpeedRPC(float amount)
    {
        throw new System.NotImplementedException();
    }

    public event GlobalDelegates.OneParameterDelegate<float> OnDecreaseCurrentMoveSpeed;
    public event GlobalDelegates.OneParameterDelegate<float> OnDecreaseCurrentMoveSpeedFeedback;
    public void RequestMove(Vector3 position)
    {
        throw new System.NotImplementedException();
    }

    public void RequestMoveDir(Vector3 direction)
    {
        throw new System.NotImplementedException();
    }

    public void SyncMoveRPC(Vector3 position)
    {
        throw new System.NotImplementedException();
    }

    public void MoveRPC(Vector3 position)
    {
        throw new System.NotImplementedException();
    }

    public event GlobalDelegates.OneParameterDelegate<Vector3> OnMove;
    public event GlobalDelegates.OneParameterDelegate<Vector3> OnMoveFeedback;
    public float GetMaxHp()
    {
        throw new NotImplementedException();
    }

    public float GetCurrentHp()
    {
        throw new NotImplementedException();
    }

    public float GetCurrentHpPercent()
    {
        throw new NotImplementedException();
    }

    public void RequestSetMaxHp(float value)
    {
        throw new NotImplementedException();
    }

    public void SyncSetMaxHpRPC(float value)
    {
        throw new NotImplementedException();
    }

    public void SetMaxHpRPC(float value)
    {
        throw new NotImplementedException();
    }

    public event GlobalDelegates.OneParameterDelegate<float> OnSetMaxHp;
    public event GlobalDelegates.OneParameterDelegate<float> OnSetMaxHpFeedback;
    public void RequestIncreaseMaxHp(float amount)
    {
        throw new NotImplementedException();
    }

    public void SyncIncreaseMaxHpRPC(float amount)
    {
        throw new NotImplementedException();
    }

    public void IncreaseMaxHpRPC(float amount)
    {
        throw new NotImplementedException();
    }

    public event GlobalDelegates.OneParameterDelegate<float> OnIncreaseMaxHp;
    public event GlobalDelegates.OneParameterDelegate<float> OnIncreaseMaxHpFeedback;
    public void RequestDecreaseMaxHp(float amount)
    {
        throw new NotImplementedException();
    }

    public void SyncDecreaseMaxHpRPC(float amount)
    {
        throw new NotImplementedException();
    }

    public void DecreaseMaxHpRPC(float amount)
    {
        throw new NotImplementedException();
    }

    public event GlobalDelegates.OneParameterDelegate<float> OnDecreaseMaxHp;
    public event GlobalDelegates.OneParameterDelegate<float> OnDecreaseMaxHpFeedback;
    public void RequestSetCurrentHp(float value)
    {
        throw new NotImplementedException();
    }

    public void SyncSetCurrentHpRPC(float value)
    {
        throw new NotImplementedException();
    }

    public void SetCurrentHpRPC(float value)
    {
        throw new NotImplementedException();
    }

    public event GlobalDelegates.OneParameterDelegate<float> OnSetCurrentHp;
    public event GlobalDelegates.OneParameterDelegate<float> OnSetCurrentHpFeedback;
    public void RequestSetCurrentHpPercent(float value)
    {
        throw new NotImplementedException();
    }

    public void SyncSetCurrentHpPercentRPC(float value)
    {
        throw new NotImplementedException();
    }

    public void SetCurrentHpPercentRPC(float value)
    {
        throw new NotImplementedException();
    }

    public event GlobalDelegates.OneParameterDelegate<float> OnSetCurrentHpPercent;
    public event GlobalDelegates.OneParameterDelegate<float> OnSetCurrentHpPercentFeedback;
    public void RequestIncreaseCurrentHp(float amount)
    {
        throw new NotImplementedException();
    }

    public void SyncIncreaseCurrentHpRPC(float amount)
    {
        throw new NotImplementedException();
    }

    public void IncreaseCurrentHpRPC(float amount)
    {
        throw new NotImplementedException();
    }

    public event GlobalDelegates.OneParameterDelegate<float> OnIncreaseCurrentHp;
    public event GlobalDelegates.OneParameterDelegate<float> OnIncreaseCurrentHpFeedback;
    
    
    public void RequestDecreaseCurrentHp(float amount)
    {
        Debug.Log(gameObject.name + " attack :" + currentAttackTarget.name + " : with " + amount +" damages");
        photonView.RPC("DecreaseCurrentHpRPC", RpcTarget.MasterClient, amount);
    }
    
    [PunRPC]
    public void SyncDecreaseCurrentHpRPC(float amount)
    {
        currentHealth = amount;
    }

    [PunRPC]
    public void DecreaseCurrentHpRPC(float amount)
    {
        currentHealth -= amount;
        if (currentHealth < 0) currentHealth = 0;
        
        photonView.RPC("SyncDecreaseCurrentHpRPC", RpcTarget.All, currentHealth);
        
        if (currentHealth <= 0)
        {
            RequestDie();     
        }
    }

    public event GlobalDelegates.OneParameterDelegate<float> OnDecreaseCurrentHp;
    public event GlobalDelegates.OneParameterDelegate<float> OnDecreaseCurrentHpFeedback;
    public bool IsAlive()
    {
        throw new NotImplementedException();
    }

    public bool CanDie()
    {
        throw new NotImplementedException();
    }

    public void RequestSetCanDie(bool value)
    {
        throw new NotImplementedException();
    }

    public void SyncSetCanDieRPC(bool value)
    {
        throw new NotImplementedException();
    }

    public void SetCanDieRPC(bool value)
    {
        throw new NotImplementedException();
    }

    public event GlobalDelegates.OneParameterDelegate<bool> OnSetCanDie;
    public event GlobalDelegates.OneParameterDelegate<bool> OnSetCanDieFeedback;
    
    public void RequestDie()
    {
        photonView.RPC("DieRPC", RpcTarget.MasterClient);
    }

    [PunRPC]
    public void SyncDieRPC()
    {
      //  PoolNetworkManager.Instance.PoolRequeue(this);
        FogOfWarManager.Instance.RemoveFOWViewable(this);
        gameObject.SetActive(false);
    }
    
    [PunRPC]
    public void DieRPC()
    {
        photonView.RPC("SyncDieRPC", RpcTarget.All);
    }

    public event GlobalDelegates.NoParameterDelegate OnDie;
    public event GlobalDelegates.NoParameterDelegate OnDieFeedback;
    public void RequestRevive()
    {
        throw new NotImplementedException();
    }

    public void SyncReviveRPC()
    {
        throw new NotImplementedException();
    }

    public void ReviveRPC()
    {
        throw new NotImplementedException();
    }

    public event GlobalDelegates.NoParameterDelegate OnRevive;
    public event GlobalDelegates.NoParameterDelegate OnReviveFeedback;
}
