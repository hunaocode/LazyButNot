//
//  LazyButNotTests.swift
//  LazyButNotTests
//
//  Created by 胡国彬 on 2026/11/13.
//  Copyright © 2026 kl. All rights reserved.
//

import Testing

@testable import LazyButNot

struct LazyButNotTests {

    @Test("应用模块可以加载")
    func appModuleCanLoad() {
        #expect(true)
    }

    @Test("目标周期持久化值保持稳定")
    func goalPeriodRawValuesRemainStable() {
        #expect(GoalPeriodType.daily.rawValue == "daily")
        #expect(GoalPeriodType.weeklyFixedDays.rawValue == "weekly_fixed_days")
        #expect(GoalPeriodType.weeklyCount.rawValue == "weekly")
    }

}
