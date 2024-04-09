using System;
using System.Collections.Generic;
using System.Linq;
using Entities.Capacities;
using Entities.FogOfWar;
using GameStates;
using Photon.Pun;
using UnityEngine;

namespace Entities
{
    [RequireComponent(typeof(PhotonView))]
    public abstract partial class Entity : MonoBehaviourPun, ITeamable
    {
        [Header("Entity")] [Header("Base")]
        /// <summary>
        /// The viewID of the photonView of the entity.
        /// </summary>
        public int entityIndex;

        [Header("Passives Capacity")]
        /// <summary>
        /// True if passiveCapacities can be added to the entity's passiveCapacitiesList. False if not.
        /// </summary>
        [SerializeField]
        public bool canAddPassiveCapacity = true;

        public EntityFogOfWarColliderLinker entityFowShowableLinker;
        /// <summary>
        /// True if passiveCapacities can be removed from the entity's passiveCapacitiesList. False if not.
        /// </summary>
        [SerializeField] private bool canRemovePassiveCapacity = true;

        /// <summary>
        /// The list of PassiveCapacity on the entity.
        /// </summary>
        public readonly List<PassiveCapacity> passiveCapacitiesList = new List<PassiveCapacity>();

        [Header("UI")]
        /// <summary>
        /// The transform of the UI of the entity.
        /// </summary>
        public Transform uiTransform;
        
        /// <summary>
        /// The offset of the UI of the entity.
        /// </summary>
        public Vector3 offset = new Vector3(0, 2f, 0);

        public EntityCapacityCollider entityCapacityCollider;
        private void Start()
        {
            entityIndex = photonView.ViewID;
            EntityCollectionManager.AddEntity(this);
            OnStart();
            
        }

        /// <summary>
        /// Replaces the Start() method.
        /// </summary>
        protected virtual void OnStart()
        {
            
        }

        private void Update()
        {
           
            OnUpdate();
        }

        private void FixedUpdate()
        {
            OnFixedUpdate();
        }

        /// <summary>
        /// Replaces the Update() method.
        /// </summary>
        protected virtual void OnUpdate()
        {
        }

        protected virtual void OnFixedUpdate()
        {
        }

        #region MasterMethods

        public void SendSyncInstantiate(Vector3 position, Quaternion rotation)
        {
            photonView.RPC("SyncInstantiateRPC", RpcTarget.All, position, rotation);
            OnInstantiated();
         
        }

        protected void ClearBushes()
        {
            for (int i = 0; i < bushes.Count; i++)
            {
                bushes[i].entitiesInside.Remove(this);
            }

            bushes.Clear();
        }

        public void SendSyncDeainstantiate()
        {
            photonView.RPC("SyncDeainstantiateRPC", RpcTarget.All);
            OnDeainstantiated();
            ClearBushes();
        }

        public virtual void OnInstantiated()
        {
        }

        public virtual void OnDeainstantiated()
        {
        }

        public virtual void OnDeainstantiatedFeedback()
        {
        }

        [PunRPC]
        public void SyncDeainstantiateRPC()
        {
            gameObject.SetActive(false);
            OnDeainstantiatedFeedback();
        }

        [PunRPC]
        public void SyncInstantiateRPC(Vector3 position, Quaternion rotation)
        {
            transform.position = position;
            transform.rotation = rotation;
            gameObject.SetActive(true);
     
            OnInstantiatedFeedback();
        }

        public virtual void TriggerEnter(Collider other)
        {
            if (other.tag == "Bush")
            {
                Bush bush = other.GetComponent<Bush>();
                bush.entitiesInside.Add(this);
                bushes.Add(bush);
            }

            if (other.tag == "Elevation")
            {
                isElevated = true;
            }
        }

        public virtual void TriggerExit(Collider other)
        {
            if (other.tag == "Bush")
            {
                Bush bush = other.GetComponent<Bush>();
                bush.entitiesInside.Remove(this);
                bushes.Remove(bush);
            }
            
            if (other.tag == "Elevation")
            {
                isElevated = false;
            }
        }

        private void OnTriggerEnter(Collider other)
        {
            TriggerEnter(other);
        }

        private void OnTriggerExit(Collider other)
        {
            TriggerExit(other);
        }


        public PassiveCapacity GetPassiveCapacityBySOIndex(byte soIndex)
        {
            return passiveCapacitiesList.FirstOrDefault(item => item.indexOfSo == soIndex);
        }

        public virtual void OnInstantiatedFeedback()
        {
        }

        /// <summary>
        /// Sends an RPC to the master to set the value canAddPassiveCapacity.
        /// </summary>
        /// <param name="value">The value to set canAddPassiveCapacity to</param>
        [PunRPC]
        private void SyncSetCanAddPassiveCapacityRPC(bool value)
        {
            photonView.RPC("SetCanAddPassiveCapacityRPC", RpcTarget.All, value);
        }

        /// <summary>
        /// Sets if passiveCapacities can be added to the entity's passiveCapacitiesList.
        /// </summary>
        /// <param name="value">true if they can, false if not</param>
        [PunRPC]
        public void SetCanAddPassiveCapacityRPC(bool value)
        {
            canAddPassiveCapacity = value;
        }

        /// <summary>
        /// Sends an RPC to the master to set the value canRemovePassiveCapacity.
        /// </summary>
        /// <param name="value">The value to set canRemovePassiveCapacity to</param>
        [PunRPC]
        private void SyncSetCanRemovePassiveCapacityRPC(bool value)
        {
            photonView.RPC("SetCanRemovePassiveCapacityRPC", RpcTarget.All, value);
        }

        /// <summary>
        /// Sets if passiveCapacities can be removed the entity's passiveCapacitiesList.
        /// </summary>
        /// <param name="value">true if they can, false if not</param>
        [PunRPC]
        private void SetCanRemovePassiveCapacityRPC(bool value)
        {
            canRemovePassiveCapacity = value;
        }

        /// <summary>
        /// Adds a PassiveCapacity to the passiveCapacityList.
        /// </summary>
        /// <param name="index">The index of the PassiveCapacitySO of the PassiveCapacity to add</param>
        public void RequestAddPassiveCapacity(byte index)
        {
            var passiveCapacitySo = CapacitySOCollectionManager.Instance.GetPassiveCapacitySOByIndex(index);
            if (!canAddPassiveCapacity || !passiveCapacitySo.TryAdded(this)) return;
            var capacity = CapacitySOCollectionManager.Instance.CreatePassiveCapacity(index, this);
            if (!passiveCapacitiesList.Contains(capacity)) passiveCapacitiesList.Add(capacity);
            photonView.RPC("SyncAddPassiveCapacityRPC", RpcTarget.Others, index);
            capacity.OnAdded(this);
            capacity.SyncOnAdded(this);
            OnPassiveCapacityAdded?.Invoke(index);
        }

        [PunRPC]
        public void SyncAddPassiveCapacityRPC(byte index)
        {
            var capacity = CapacitySOCollectionManager.Instance.CreatePassiveCapacity(index, this);
            if (!passiveCapacitiesList.Contains(capacity)) passiveCapacitiesList.Add(capacity);
            capacity.SyncOnAdded(this);
         
            OnPassiveCapacityAddedFeedbacks?.Invoke(index);
        }

        public void RequestRemovePassiveCapacity(byte index)
        {
            if (index >= passiveCapacitiesList.Count) return;
            var capacity = passiveCapacitiesList[index];
       
            capacity.OnRemoved(this);
            OnPassiveCapacityRemoved?.Invoke(index);
            photonView.RPC("SyncRemovePassiveCapacityRPC", RpcTarget.All, index);
        }

        [PunRPC]
        public void SyncRemovePassiveCapacityRPC(byte index)
        {
            passiveCapacitiesList[index].SyncOnRemoved(this);
            passiveCapacitiesList.RemoveAt(index);
            OnPassiveCapacityRemovedFeedbacks?.Invoke(index);
        }

        public event GlobalDelegates.OneParameterDelegate<byte> OnPassiveCapacityAdded;
        public event GlobalDelegates.OneParameterDelegate<byte> OnPassiveCapacityRemoved;
        public event GlobalDelegates.OneParameterDelegate<byte> OnPassiveCapacityAddedFeedbacks;
        public event GlobalDelegates.OneParameterDelegate<byte> OnPassiveCapacityRemovedFeedbacks;

        #endregion
    }
}