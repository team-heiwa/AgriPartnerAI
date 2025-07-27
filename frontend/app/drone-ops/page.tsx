'use client'

import React, { useState } from 'react'
import MainLayout from '../../components/MainLayout'
import ManualDroneControl from '../../components/drone-ops/ManualDroneControl'
import RouteReservation from '../../components/drone-ops/RouteReservation'

export default function DroneOps() {
  const [activeTab, setActiveTab] = useState<'manual' | 'route'>('manual')

  return (
    <MainLayout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <h1 className="text-2xl font-bold text-gray-800">Drone Operations</h1>
          <div className="flex items-center gap-2 text-sm">
            <div className="w-2 h-2 bg-risk-ok rounded-full"></div>
            <span>Drone Status: Online</span>
          </div>
        </div>

        {/* タブナビゲーション */}
        <div className="bg-white rounded-lg shadow-md">
          <div className="flex border-b">
            <button
              onClick={() => setActiveTab('manual')}
              className={`
                flex-1 px-6 py-4 text-center font-medium transition-colors
                ${activeTab === 'manual'
                  ? 'text-blue-600 border-b-2 border-blue-600 bg-blue-50'
                  : 'text-gray-600 hover:text-gray-800 hover:bg-gray-50'
                }
              `}
            >
              🕹️ Manual Control
            </button>
            <button
              onClick={() => setActiveTab('route')}
              className={`
                flex-1 px-6 py-4 text-center font-medium transition-colors
                ${activeTab === 'route'
                  ? 'text-blue-600 border-b-2 border-blue-600 bg-blue-50'
                  : 'text-gray-600 hover:text-gray-800 hover:bg-gray-50'
                }
              `}
            >
              🗓️ Route Reservation
            </button>
          </div>

          <div className="p-6">
            {activeTab === 'manual' && <ManualDroneControl />}
            {activeTab === 'route' && <RouteReservation />}
          </div>
        </div>
      </div>
    </MainLayout>
  )
}