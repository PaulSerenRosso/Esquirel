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
            Ressource++;
        }
        
        public override void DecreaseRessource(int amount)
        {
            Ressource--;
        }
        
        [PunRPC]
        void IncreaseAuraCapacityRPC(int index)
        {
            if (Ressource > 0 && auraCapacityCounts[index] == so.passiveCapacitySo[index].maxCount)
            {
                DecreaseRessource(so.passiveCapacitySo[index].auraCost);
                champion.RequestAddPassiveCapacity(so.passiveCapacitySo[index].indexInCollection);
                photonView.RPC("SyncIncreaseAuraCapacityRPC", RpcTarget.MasterClient, index);
            }
        }
        [PunRPC]
        public void SyncIncreaseAuraCapacityRPC(int index)
        {
            auraCapacityCounts[index]++;
        }

        public void RequestIncreaseAuraCapacity(int index)
        {
            if (Ressource > 0 && auraCapacityCounts[index] == so.passiveCapacitySo[index].maxCount)


                photonView.RPC("IncreaseAuraCapacityRPC", RpcTarget.MasterClient, index);
        }

        public void UpdateAuraCapacityCounts(PassiveCapacityAuraSO auraSo, int valueCount)
        {
           auraCapacityCounts[Array.IndexOf(so.passiveCapacitySo, auraSo)] = valueCount;
        }
    }
}