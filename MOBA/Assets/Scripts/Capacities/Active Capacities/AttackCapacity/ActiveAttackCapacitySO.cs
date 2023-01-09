using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

namespace Entities.Capacities
{
    public abstract class ActiveAttackCapacitySO : ActiveCapacitySO
    {
        public ActiveCapacityAnimationLauncherInfo activeCapacityAnimationLauncherInfo;
        public float damage;
        public float offsetAttack;
        public float damageBeginTime;
        public float impactFxTime;
        public float damageTime;
        public float attackTime;
        public AttackCapacityImpactFx attackCapacityImpactFx;
    }
}