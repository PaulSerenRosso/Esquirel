using System;
using System.Collections.Generic;
using Entities.FogOfWar;
using System.Linq;
using Photon.Pun;
using UnityEngine;
using UnityEngine.Rendering;

namespace Entities
{
    
    public abstract partial class Entity : IFOWViewable
    {
        [Header("FOW Viewable")]
        public bool canChangeTeam;
        public Enums.Team team;

        public float baseViewRange;
        public float viewRange;
        [Range(0, 360)] public float viewAngle;
        public bool canView;
        public List<IFOWShowable> seenShowables = new List<IFOWShowable>();
        public MeshFilter meshFilterFoV;

        public Enums.Team GetTeam()
        {
            return team;
        }

        public List<Enums.Team> GetEnemyTeams()
        {
            return Enum.GetValues(typeof(Enums.Team)).Cast<Enums.Team>().Where(someTeam => someTeam != team)
                .ToList(); //returns all teams that are not 'team'
        }

        public bool CanChangeTeam()
        {
            return canChangeTeam;
        }

        public void RequestChangeTeam(Enums.Team team)
        {
            photonView.RPC("ChangeTeamRPC", RpcTarget.MasterClient, (byte)team);
        }

        [PunRPC]
        public void SyncChangeTeamRPC(byte team)
        {
            this.team = (Enums.Team)team;
        }

        [PunRPC]
        public void ChangeTeamRPC(byte team)
        {
            photonView.RPC("SyncChangeTeamRPC", RpcTarget.All, team);
        }

        public event GlobalDelegates.OneParameterDelegate<bool> OnChangeTeam;
        public event GlobalDelegates.OneParameterDelegate<bool> OnChangeTeamFeedback;

        public bool CanView() => canView;
        public float GetFOWViewRange() => viewRange;
        public float GetFOWBaseViewRange() => baseViewRange;

        public List<IFOWShowable> SeenShowables() => seenShowables;

        public void RequestSetCanView(bool value)
        {
            photonView.RPC("SetCanViewRPC", RpcTarget.MasterClient, value);
        }

        [PunRPC]
        public void SyncSetCanViewRPC(bool value)
        {
            canView = value;
            OnSetCanViewFeedback?.Invoke(value);
        }

        [PunRPC]
        public void SetCanViewRPC(bool value)
        {
            canView = value;
            OnSetCanView?.Invoke(value);
            photonView.RPC("SetCanViewRPC", RpcTarget.All, value);
        }

        public event GlobalDelegates.OneParameterDelegate<bool> OnSetCanView;
        public event GlobalDelegates.OneParameterDelegate<bool> OnSetCanViewFeedback;

        public void RequestSetViewRange(float value)
        {
            photonView.RPC("SyncSetViewRangeRPC", RpcTarget.MasterClient, value);
        }

        [PunRPC]
        public void SyncSetViewRangeRPC(float value)
        {
            viewRange = value;
            OnSetViewRangeFeedback?.Invoke(value);
        }

        [PunRPC]
        public void SetViewRangeRPC(float value)
        {
            viewRange = value;
            OnSetViewRange?.Invoke(value);
            photonView.RPC("SyncSetViewRangeRPC", RpcTarget.All, value);
        }

        public event GlobalDelegates.OneParameterDelegate<float> OnSetViewRange;
        public event GlobalDelegates.OneParameterDelegate<float> OnSetViewRangeFeedback;

        public void RequestSetViewAngle(float value)
        {
            photonView.RPC("SyncSetViewAngleRPC", RpcTarget.MasterClient, value);
        }

        [PunRPC]
        public void SyncSetViewAngleRPC(float value)
        {
            viewAngle = value;
            OnSetViewAngleFeedback?.Invoke(value);
        }
        [PunRPC]
        public void SetViewAngleRPC(float value)
        {
            viewAngle = value;
            OnSetViewAngle?.Invoke(value);
            photonView.RPC("SyncSetViewAngleRPC", RpcTarget.All, value);
        }

        public event GlobalDelegates.OneParameterDelegate<float> OnSetViewAngle;
        public event GlobalDelegates.OneParameterDelegate<float> OnSetViewAngleFeedback;

        public void RequestSetBaseViewRange(float value)
        {
            photonView.RPC("SetBaseViewRangeRPC", RpcTarget.MasterClient, value);
        }

        [PunRPC]
        public void SyncSetBaseViewRangeRPC(float value)
        {
            baseViewRange = value;
            OnSetBaseViewRangeFeedback?.Invoke(value);
        }

        [PunRPC]
        public void SetBaseViewRangeRPC(float value)
        {
            baseViewRange = value;
            OnSetBaseViewRange?.Invoke(value);
            photonView.RPC("SyncSetBaseViewRangeRPC", RpcTarget.All, value);
        }

        public event GlobalDelegates.OneParameterDelegate<float> OnSetBaseViewRange;
        public event GlobalDelegates.OneParameterDelegate<float> OnSetBaseViewRangeFeedback;

        public void AddShowable(int seenEntityIndex)
        {
            var entity = EntityCollectionManager.GetEntityByIndex(seenEntityIndex);
            if (entity == null) return;
         

            AddShowable(entity);
        }

        
        public void AddShowable(Entity showable)
        {
            if (seenShowables.Contains(showable)) return;
            if(!CheckBushCondition(showable)) return;
            seenShowables.Add(showable);
            //Debug.Log("seen Showable Add");
            showable.TryAddFOWViewable(this);
            //Debug.Log("Try add This FowViewable");
            var seenEntityIndex = ((Entity)showable).entityIndex;
            //Debug.Log("Entity index : " + seenEntityIndex);
            OnAddShowableFeedback?.Invoke(seenEntityIndex);

            
         //   if (!PhotonNetwork.IsMasterClient) return;
           // OnAddShowable?.Invoke(seenEntityIndex);
            //photonView.RPC("SyncAddShowableRPC", RpcTarget.All, seenEntityIndex);
        }

        [PunRPC]
        public void SyncAddShowableRPC(int seenEntityIndex)
        {
            var entity = EntityCollectionManager.GetEntityByIndex(seenEntityIndex);
            if (entity == null) return;

            var showable = entity.GetComponent<IFOWShowable>();
            if (showable == null) return;
            if (seenShowables.Contains(showable)) return;

            seenShowables.Add(showable);
            OnAddShowableFeedback?.Invoke(seenEntityIndex);
         //    if (!PhotonNetwork.IsMasterClient) showable.TryAddFOWViewable(this);
        }

        public bool CheckBushCondition(Entity showable)
        {
            if (showable.currentBush != null)
            {
            if(this.currentBush == null) return false;
            if(currentBush != showable.currentBush) return false;
            return true;
            }
            return true;
        }

        public event GlobalDelegates.OneParameterDelegate<int> OnAddShowable;
        public event GlobalDelegates.OneParameterDelegate<int> OnAddShowableFeedback;

        public void RemoveShowable(int seenEntityIndex)
        {
            var entity = EntityCollectionManager.GetEntityByIndex(seenEntityIndex);
            if (entity == null) return;

            var showable = entity.GetComponent<IFOWShowable>();
            if (showable == null) return;

            RemoveShowable(showable);
        }

        public void RemoveShowable(IFOWShowable showable)
        {
            if (!seenShowables.Contains(showable)) return;

            seenShowables.Remove(showable);
            //Debug.Log("Remove Showable");
            showable.TryRemoveFOWViewable(this);
            //Debug.Log("TryRemoveFOWViewable");
            
            var seenEntityIndex = ((Entity)showable).entityIndex;
            //Debug.Log("Entity Index : " + ((Entity)showable).entityIndex);
            OnRemoveShowableFeedback?.Invoke(seenEntityIndex);

            //    if (!PhotonNetwork.IsMasterClient) return;
            //     OnRemoveShowable?.Invoke(seenEntityIndex);
            //     photonView.RPC("SyncRemoveShowableRPC", RpcTarget.All, seenEntityIndex);
        }

        [PunRPC]
        public void SyncRemoveShowableRPC(int seenEntityIndex)
        {
            var entity = EntityCollectionManager.GetEntityByIndex(seenEntityIndex);
            if (entity == null) return;

            var showable = entity.GetComponent<IFOWShowable>();
            if (showable == null) return;
            if (!seenShowables.Contains(showable)) return;

            seenShowables.Remove(showable);
            OnAddShowableFeedback?.Invoke(seenEntityIndex);
            //     if (!PhotonNetwork.IsMasterClient) showable.TryRemoveFOWViewable(this);
        }

        public event GlobalDelegates.OneParameterDelegate<int> OnRemoveShowable;
        public event GlobalDelegates.OneParameterDelegate<int> OnRemoveShowableFeedback;

  
    }
}