'use client'

import React, { useState } from 'react'
import MainLayout from '../../components/MainLayout'
import ReportGenerator from '../../components/reports/ReportGenerator'
import ReportHistory from '../../components/reports/ReportHistory'
import ReportPreview from '../../components/reports/ReportPreview'

export default function Reports() {
  const [activeTab, setActiveTab] = useState<'generate' | 'history'>('generate')
  const [selectedReport, setSelectedReport] = useState<string | null>(null)

  return (
    <MainLayout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <h1 className="text-2xl font-bold text-gray-800">Reports</h1>
          <div className="flex items-center gap-4">
            <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors">
              📊 新規レポート
            </button>
            <button className="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 transition-colors">
              📤 一括エクスポート
            </button>
          </div>
        </div>

        {/* タブナビゲーション */}
        <div className="bg-white rounded-lg shadow-md">
          <div className="flex border-b">
            <button
              onClick={() => setActiveTab('generate')}
              className={`
                flex-1 px-6 py-4 text-center font-medium transition-colors
                ${activeTab === 'generate'
                  ? 'text-blue-600 border-b-2 border-blue-600 bg-blue-50'
                  : 'text-gray-600 hover:text-gray-800 hover:bg-gray-50'
                }
              `}
            >
              📝 レポート生成
            </button>
            <button
              onClick={() => setActiveTab('history')}
              className={`
                flex-1 px-6 py-4 text-center font-medium transition-colors
                ${activeTab === 'history'
                  ? 'text-blue-600 border-b-2 border-blue-600 bg-blue-50'
                  : 'text-gray-600 hover:text-gray-800 hover:bg-gray-50'
                }
              `}
            >
              📋 履歴・管理
            </button>
          </div>

          <div className="p-6">
            {activeTab === 'generate' ? (
              <div className="grid grid-cols-1 xl:grid-cols-3 gap-6">
                {/* レポート生成 */}
                <div className="xl:col-span-2">
                  <ReportGenerator onPreview={setSelectedReport} />
                </div>

                {/* プレビュー */}
                <div className="xl:col-span-1">
                  <ReportPreview reportId={selectedReport} />
                </div>
              </div>
            ) : (
              <ReportHistory onReportSelect={setSelectedReport} />
            )}
          </div>
        </div>
      </div>
    </MainLayout>
  )
}