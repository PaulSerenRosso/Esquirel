using System;
using System.Collections.Generic;
using AlgebraHelpers;
using Controllers;
using Entities.Capacities;
using Entities.FogOfWar;
using GameStates;
using MiniMap;
using Photon.Pun;

using UnityEngine;
using UnityEngine.AI;

namespace Entities.Champion
{
    public partial class Champion : Entity
    {
        public CatapultMovment catapultMovment;
        public PhotonTransformView transformView;
        public ChampionSO championSo;
        public Transform rotateParent;
        public Transform championMesh;
        private Vector3 respawnPos;
        [SerializeField]
        public float pointPlacerDistanceAvoidance;
        private FogOfWarManager fowm;
        private CapacitySOCollectionManager capacityCollection;
        private UIManager uiManager;
        public Camera camera;
        public Rigidbody rb;
        public ChampionPlacerDistanceAvoider championPlacerDistanceAvoider;

        public float pointPlacerColliderRadius;
        [SerializeField] public EntityClicker entityClicker;
        public Animator animator;
        public CollisionBlocker blocker;
        [SerializeField] public NavMeshObstacle obstacle;

        public ActiveCapacity attackBase;
        public List<ActiveCapacity> activeCapacities = new List<ActiveCapacity>();
        public ActiveCapacity currentCapacityUsed;
        public IAimable autoAttack;


        private void OnDrawGizmosSelected()
        {
            Gizmos.color = Color.yellow;
            Gizmos.DrawWireSphere(transform.position, pointPlacerDistanceAvoidance);
        }

        protected override void OnStart()
        {
            base.OnStart();
            fowm = FogOfWarManager.Instance;
            capacityCollection = CapacitySOCollectionManager.Instance;
            uiManager = UIManager.Instance;
            camera = Camera.main;
            uiManager = UIManager.Instance;
            agent = GetComponent<NavMeshAgent>();
            obstacle = GetComponent<NavMeshObstacle>();
            fowm.AddFOWViewable(this );
            blocker.SetUpBlocker();
            Instantiate(new GameObject());
        }

        protected override void OnUpdate()
        {
            if (isFollowing) FollowEntity(); // Lol
            if (!photonView.IsMine) return;
            CheckMoveDistance();
        }


        public override void OnInstantiated()
        {
            base.OnInstantiated();
        }

        public override void OnInstantiatedFeedback()
        {
        }


        public void ApplyChampionSO(byte championSoIndex, Enums.Team newTeam)
        {
            var so = GameStateMachine.Instance.allChampionsSo[championSoIndex];
            championSo = so;
            maxHp = championSo.maxHp;
            currentHp = maxHp;
            maxResource = championSo.maxRessource;
            currentResource = championSo.maxRessource;
            viewRange = championSo.viewRange;
            referenceMoveSpeed = championSo.referenceMoveSpeed;
            currentMoveSpeed = referenceMoveSpeed;
            attackDamage = championSo.attackDamage;
            attackAbilityIndex = championSo.attackAbilityIndex;
            abilitiesIndexes = championSo.activeCapacitiesIndexes;
            ultimateAbilityIndex = championSo.ultimateAbilityIndex;
            var championMesh = Instantiate(championSo.championMeshPrefab, rotateParent.position,
                Quaternion.identity, rotateParent);
            championMesh.transform.localEulerAngles = Vector3.zero;
            GetComponent<MiniMapIcon>().SetSprite(championSo.championIcon);
          

            team = newTeam;

            Transform pos = transform;
            switch (team)
            {
                case Enums.Team.Team1:
                {
                    for (int i = 0; i < MapLoaderManager.Instance.firstTeamBasePoint.Length; i++)
                    {
                        if (MapLoaderManager.Instance.firstTeamBasePoint[i].champion == null)
                        {
                            pos = MapLoaderManager.Instance.firstTeamBasePoint[i].position;
                            MapLoaderManager.Instance.firstTeamBasePoint[i].champion = this;
                            break;
                        }
                    }

                    break;
                }
                case Enums.Team.Team2:
                {
                    for (int i = 0; i < MapLoaderManager.Instance.secondTeamBasePoint.Length; i++)
                    {
                        if (MapLoaderManager.Instance.secondTeamBasePoint[i].champion == null)
                        {
                            pos = MapLoaderManager.Instance.secondTeamBasePoint[i].position;
                            MapLoaderManager.Instance.secondTeamBasePoint[i].champion = this;
                            break;
                        }
                    }

                    break;
                }
                default:
                    Debug.LogError("Team is not valid.");
                    pos = transform;
                    break;
            }

        
            respawnPos = transform.position = pos.position;
            SetupNavMesh();


            var championMeshLinker = championMesh.GetComponent<ChampionMeshLinker>();
            championMeshLinker.LinkTeamColor(this.team);
            animator = championMeshLinker.animator; 
            
     

            uiManager = UIManager.Instance;

            if (uiManager != null)
            {
                uiManager.InstantiateHealthBarForEntity(entityIndex);
             //   uiManager.InstantiateResourceBarForEntity(entityIndex);
            }
            so.SetIndexes();
          
            for (int i = 0; i < so.activeCapacities.Length; i++)
            {
                activeCapacities.Add(CapacitySOCollectionManager.CreateActiveCapacity(so.activeCapacities[i].indexInCollection,this));
            }
            for (int i = 0; i < so.activeCapacities.Length; i++)
            {
                activeCapacities[i].SetUpActiveCapacity(so.activeCapacities[i].indexInCollection, this);
            }
            activeCapacities.Add(CapacitySOCollectionManager.CreateActiveCapacity(so.ultimateAbility.indexInCollection,this));
            activeCapacities[activeCapacities.Count-1].SetUpActiveCapacity(so.ultimateAbility.indexInCollection, this);
            attackBase =
                CapacitySOCollectionManager.CreateActiveCapacity(so.attackAbility.indexInCollection, this);
            autoAttack =(IAimable) attackBase;
            attackBase.SetUpActiveCapacity(so.attackAbility.indexInCollection, this);
            if (PhotonNetwork.IsMasterClient)
            {
            for (int i = 0; i < so.passiveCapacitiesIndexes.Length; i++)
            {
                RequestAddPassiveCapacity(so.passiveCapacitiesIndexes[i]);
            }
            }
            championMesh.GetComponent<EntityFOWShowableLinker>().LinkEntity(this);
            if (GameStates.GameStateMachine.Instance.GetPlayerTeam() != team)
            {
                HideElements();
            }
            rb.velocity = Vector3.zero;
            RequestSetCanDie(true);
        }

        public void RequestChangeBoolParameterAnimator(string parameterName, bool value)
        {
            photonView.RPC("ChangeBoolParameterAnimator", RpcTarget.All, parameterName, value);
        }

        [PunRPC]
        void ChangeBoolParameterAnimator(string parameterName, bool value)
        {
            
            animator.SetBool(parameterName, value);
        }
        
        
        public void RequestSetCurrentCapacityUsed(byte index)
        {
            photonView.RPC("SetCurrentCapacityUsed", RpcTarget.All, index);
        }

        [PunRPC]
        void SetCurrentCapacityUsed(byte index)
        {
            currentCapacityUsed = activeCapacities[index];
        }
        
        public void RequestSetCurrentCapacityUsedEqualToAttackBase()
        {
            photonView.RPC("SetCurrentCapacityUsedEqualToAttackBase", RpcTarget.All);
        }
        [PunRPC]
        void SetCurrentCapacityUsedEqualToAttackBase()
        {
            currentCapacityUsed = attackBase;
        }
  
        public void RequestIncreaseHealAmountOfPerseverance(float amount)
        {
            photonView.RPC("IncreaseHealAmountOfPerseverance", RpcTarget.MasterClient, amount);
        }

        [PunRPC]
        public void IncreaseHealAmountOfPerseverance(float amount)
        {
            PassivePerseverance passivePerseverance = (PassivePerseverance)passiveCapacitiesList[0];
            passivePerseverance.healPercentage += amount;
            Debug.Log(passivePerseverance.healPercentage);
            if(!passivePerseverance.healPercentage.IsClamp(0 ,1))
            {
                passivePerseverance.healPercentage = 1; 
    
            }
        }
    }
}