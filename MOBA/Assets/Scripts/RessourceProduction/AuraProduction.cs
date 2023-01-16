using System;
using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using Entities.Champion;
using Photon.Pun;
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
        }

        public override void UpdateFeedback(int value)
        {
            if (Ressource == 0 && value >= 1)
            {
                // enabled ui
            }
            else if (Ressource >= 1 && value == 0)
            {
                //disabled ui
            }
        }

        public override void IncreaseRessource(int amount)
        {
            Ressource+= amount;
        }
        
        public override void DecreaseRessource(int amount)
        {
            Ressource+= amount;
        }
        
        [PunRPC]
        void DecreaseAuraCapacityRPC(int index)
        {
            if (Ressource >= so.passiveCapacitySo[index].auraCost[auraCapacityCounts[index]] && auraCapacityCounts[index] == so.passiveCapacitySo[index].maxCount)
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
        }

        public void RequestDecreaseAuraCapacity(int index)
        {
            if (Ressource >= so.passiveCapacitySo[index].auraCost[auraCapacityCounts[index]] && auraCapacityCounts[index] == so.passiveCapacitySo[index].maxCount)
                photonView.RPC("DecreaseAuraCapacityRPC", RpcTarget.MasterClient, index);
        }

        public void UpdateAuraCapacityCounts(PassiveCapacityAuraSO auraSo, int valueCount)
        {
           auraCapacityCounts[Array.IndexOf(so.passiveCapacitySo, auraSo)] = valueCount;
        }
    }
}