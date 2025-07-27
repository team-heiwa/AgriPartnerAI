'use client'

import React from 'react'
import Link from 'next/link'
import { FaVideo } from 'react-icons/fa'
import MainLayout from '../components/MainLayout'
import RiskCard from '../components/dashboard/RiskCard'
import LiveMap from '../components/dashboard/LiveMap'
import AlertFeed from '../components/dashboard/AlertFeed'

export default function Dashboard() {
  return (
    <MainLayout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <h1 className="text-2xl font-bold text-gray-800">ダッシュボード</h1>
          <Link
            href="/visit-recorder"
            className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
          >
            <span className="flex items-center gap-1">
              <FaVideo /> Visit Recorder
            </span>
          </Link>
        </div>

        {/* リスクカード（2×2グリッド） */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <RiskCard
            type="pest"
            score={0.66}
            title="害虫リスク"
            icon="🐛"
            onClick={() => console.log('害虫カード clicked')}
          />
          <RiskCard
            type="disease"
            score={0.72}
            title="病気リスク"
            icon="🍂"
            onClick={() => console.log('病気カード clicked')}
          />
          <RiskCard
            type="pest"
            score={0.42}
            title="環境リスク"
            icon="🌦️"
            onClick={() => console.log('環境カード clicked')}
          />
          <RiskCard
            type="disease"
            score={0.28}
            title="総合健康度"
            icon="🌱"
            onClick={() => console.log('健康度カード clicked')}
          />
        </div>

        {/* メインコンテンツエリア */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* ライブマップ */}
          <LiveMap />
          
          {/* アラートフィード */}
          <AlertFeed />
        </div>
      </div>
    </MainLayout>
  )
} 