using System;
using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using Entities.Champion;
using GameStates;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;

namespace RessourceProduction
{
    public class AuraProduction : RessourceProduction<int, AuraProductionSO>
    {
        [SerializeField] private Champion champion;
        private int[] auraCapacityCounts = new int[3];

        protected override void OnStart()
        {
            base.OnStart();
            photonView.TransferOwnership(PhotonNetwork.MasterClient);
        }

        public void InitAuraProduction()
        {
            if (champion.photonView.IsMine)
            {
                UIManager.Instance.SetUpAuraSprite(0, AuraUIImage.AADamage, (() => RequestDecreaseAuraCapacity(0)));
                UIManager.Instance.SetUpAuraSprite(0, AuraUIImage.Comp01Damage, (() => RequestDecreaseAuraCapacity(1)));
                UIManager.Instance.SetUpAuraSprite(0, AuraUIImage.LifePoint, (() => RequestDecreaseAuraCapacity(2)));
                UIManager.Instance.ChangeAuraState(false);
            }
        }

        public override void UpdateFeedback(int value)
        {
  //          Debug.Log("bonsoir à tous");
            if(!champion.photonView.IsMine) return;
//            Debug.Log("bonsoir à tous");
            if (Ressource == 0 && value >= 1)
            {
                UIManager.Instance.ChangeAuraState(true);
            }
            else if (Ressource >= 1 && value == 0)
            {
                UIManager.Instance.ChangeAuraState(false);
            }
        }

        public override void IncreaseRessource(int amount)
        {
            Ressource+= amount;
        }
        
        public override void DecreaseRessource(int amount)
        {
            Ressource-= amount;
        }
        
        [PunRPC]
        void DecreaseAuraCapacityRPC(int index)
        {
            if(auraCapacityCounts[index] != so.passiveCapacitySo[index].maxCount)
            if (Ressource >= so.passiveCapacitySo[index].auraCost[auraCapacityCounts[index]])
            {
                DecreaseRessource(so.passiveCapacitySo[index].auraCost[auraCapacityCounts[index]]);
                champion.RequestAddPassiveCapacity(so.passiveCapacitySo[index].indexInCollection);
                photonView.RPC("SyncDecreaseAuraCapacityRPC", RpcTarget.All, index);
            }
        }
        [PunRPC]
        public void SyncDecreaseAuraCapacityRPC(int index)
        {
            auraCapacityCounts[index]++;
            if(!champion.photonView.IsMine) return;
            switch (index)
            {
                case 0:
                {
                    UIManager.Instance.UpdateAuraValue( auraCapacityCounts[index], AuraUIImage.AADamage);
                    break;
                }
                case 1:
                {
                    UIManager.Instance.UpdateAuraValue( auraCapacityCounts[index], AuraUIImage.Comp01Damage);
                    break;
                }
                case 2:
                {
                    UIManager.Instance.UpdateAuraValue( auraCapacityCounts[index], AuraUIImage.LifePoint);
                    break;
                }
            }
       
            Debug.Log(auraCapacityCounts[index]);
        }

        public void RequestDecreaseAuraCapacity(int index)
        {
            if(auraCapacityCounts[index] != so.passiveCapacitySo[index].maxCount)
            if (Ressource >= so.passiveCapacitySo[index].auraCost[auraCapacityCounts[index]] )
                photonView.RPC("DecreaseAuraCapacityRPC", RpcTarget.MasterClient, index);
        }


      
    }
}