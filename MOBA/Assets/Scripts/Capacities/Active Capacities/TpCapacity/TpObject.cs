using System.Collections;
using System.Collections.Generic;
using Entities;
using GameStates;
using Photon.Pun;
using UnityEngine;

namespace Entities.Capacities
{
    public class TpObject : Entity
    {
        [SerializeField] private Collider collider;
        [SerializeField] private MeshRenderer renderer;
        private bool isActive;


        protected override void OnStart()
        {
            base.OnStart();
            DeactivateTpObject();
        }

        public void RequestActivate(Vector3 startPos)
        {
            photonView.RPC("ActivateRPC", RpcTarget.All, startPos);
        }

        public bool GetIsActive()
        {
            return
                isActive;
        }

        public void RequestDeactivate()
        {
            photonView.RPC("DeactivateRPC", RpcTarget.All);
        }

        [PunRPC]
        public void ActivateRPC(Vector3 startPos, Enums.Team team)
        {
            ActivateTpObject(startPos, team);
        }

        public void ActivateTpObject(Vector3 startPos, Enums.Team team)
        {
            isActive = true;
            collider.enabled = true;
               this.team = team;
             
           if(GameStateMachine.Instance.GetPlayerTeam() == team)
               ShowElements();
           else
           {
               HideElements();
           }
        }

        [PunRPC]
        public void DeactivateRPC()
        {
            DeactivateTpObject();
        }

        public void DeactivateTpObject()
        {
            collider.enabled = false;
            isActive = false;
            HideElements();
        }
    }
}