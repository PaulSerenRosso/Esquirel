using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using UnityEngine;

namespace Entities.Capacities
{
    public class JumpWithSlowCapacityMovement : JumpMovement
    {
        private ActiveAttackSlowAreaCapacity activeAttackSlowAreaCapacity;

        public override void SetUp(byte capacityIndex, int championIndex)
        {
            base.SetUp(capacityIndex, championIndex);
            JumpWithSlowCapacity jumpWithSlowCapacity = (JumpWithSlowCapacity)champion.activeCapacities[capacityIndex];
            activeAttackSlowAreaCapacity = jumpWithSlowCapacity.activeAttackSlowAreaCapacity;
            endCurveEvent += () =>
            {
                if (PhotonNetwork.IsMasterClient)
                {
                    champion.CastRPC((byte)champion.activeCapacities.IndexOf(activeAttackSlowAreaCapacity), null, null,
                        null);
                }
            };
        }
    }
}