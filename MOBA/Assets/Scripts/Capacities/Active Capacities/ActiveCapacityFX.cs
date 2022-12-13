using System.Collections;
using System.Collections.Generic;
using Entities;
using Photon.Pun;
using UnityEngine;

namespace Entities.Capacities
{
public class ActiveCapacityFX : Entity
{
    [SerializeField]
    protected ParticleSystem[] allParticleSystems;
    [PunRPC]
    public void StartInitCapacityFX(int entityIndex, byte capacityIndex)
    {
        InitCapacityFX(entityIndex, capacityIndex);
    }
    public virtual void InitCapacityFX(int entityIndex, byte capacityIndex)
    {

        team = EntityCollectionManager.GetEntityByIndex(entityIndex).team;
    }

    public void RequestInitCapacityFX(int entityIndex, byte capacityIndex)
    {
        photonView.RPC("StartInitCapacityFX", RpcTarget.All, entityIndex, capacityIndex  );
    }
    
}

}
