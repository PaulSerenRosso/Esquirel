using System.Collections;
using System.Collections.Generic;
using Entities;
using Entities.FogOfWar;
using GameStates;
using Photon.Pun;
using UnityEngine;

namespace Entities.Capacities
{
public class ActiveCapacityFX : Entity
{
    [SerializeField]
    protected ParticleSystem[] allParticleSystems;
    [PunRPC]
    public void StartInitCapacityFX(int entityIndex, byte capacityIndex, Vector3 direction)
    {
        InitCapacityFX(entityIndex, capacityIndex,  direction);
    }
    
    public virtual void InitCapacityFX(int entityIndex, byte capacityIndex, Vector3 direction)
    {
        team = EntityCollectionManager.GetEntityByIndex(entityIndex).team;
        if(GameStateMachine.Instance.GetPlayerTeam() == team)
            ShowElements();
        else
        {
            //tendencer
            if(enemiesThatCanSeeMe.Count == 0)
            HideElements();
        }
    }
 
    public void RequestInitCapacityFX(int entityIndex, byte capacityIndex, Vector3 direction)
    {
        photonView.RPC("StartInitCapacityFX", RpcTarget.All, entityIndex, capacityIndex, direction  );
    }
    
}

}
