//
//  CalendarView.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-17.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var userInfo: UserInfo
    @ObservedObject var viewModel: MainSimViewModel
    @Binding var currentDate: Date
    @Binding var selectedDate: Date
    @Binding var teamID: Int
    @Binding var isDisabled: Bool
    @State private var season: Int = 0
    @State private var isCalendarLoaded: Bool = false
    
    var body: some View {
        VStack {
            if isCalendarLoaded {
                CalendarGridView(
                    calendar: viewModel.calendar,
                    date: $selectedDate,
                    content: dateBlock,
                    trailing: trailingBlock,
                    header: headerBlock,
                    title: titleBlock
                )
                .equatable()
                .padding(Spacing.spacingExtraSmall)
                .appButtonStyle()
                .disabled(isDisabled)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    .frame(height: 430)
            }
        }
        .onAppear {
            // Fetch the recent simulated date and season for the calendar
            viewModel.fetchSimulationDateDetails(userInfo: userInfo) { detailsFetched in
                if detailsFetched {
                    if let dateString = viewModel.simulationCurrentDate, let date = viewModel.dateFormatter.date(from: dateString) {
                        currentDate = date
                        selectedDate = date
                    }
                    if let simulationSeason = viewModel.season {
                        season = simulationSeason
                    }
                }
            }
        }
        .onChange(of: selectedDate) { newSelectedDate in
            let newSelectedMonth = viewModel.calendar.component(.month, from: newSelectedDate)
            let stringCurrentDate = viewModel.dateFormatter.string(from: currentDate)
            // Fetch the new monthly matchups on change of the date
            viewModel.fetchTeamMonthSchedule(teamID: teamID, season: season, month: newSelectedMonth) { scheduledFetched in
                if scheduledFetched {
                    // Fetch the scores of simulated games
                    viewModel.fetchTeamMatchupScores(simulationID: userInfo.simulationID, currentDate: stringCurrentDate, teamID: teamID, season: season) { scoresFetched in
                        isCalendarLoaded = scoresFetched
                    }
                }
            }
        }
        .onChange(of: teamID) { newTeamID in
            // Trigger date change and schedule refresh when the selected team changes
            isCalendarLoaded = false
            selectedDate = selectedDate.addingTimeInterval(1)
        }
        .onChange(of: viewModel.simScores.count) { _ in
            selectedDate = selectedDate.addingTimeInterval(1)
        }
    }

    // Date block
    @ViewBuilder
    private func dateBlock(date: Date) -> some View {
        Button(action: { selectedDate = date }) {
            Text(Symbols.calendarPlaceholder.rawValue)
                .frame(height: 48)
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
                .foregroundColor(.clear)
                .background(
                    viewModel.calendar.isDate(date, inSameDayAs: currentDate) ? Color.white : Color.black
                )
                .appButtonStyle()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(viewModel.calendar.isDate(date, inSameDayAs: selectedDate) ? Color.white : Color.clear, lineWidth: 2)
                )
                .overlay(
                    VStack {
                        if let scoreText = viewModel.scoreText(date: date, teamID: teamID) {
                            Text(scoreText)
                                .foregroundColor(String(scoreText.first ?? " ") == Symbols.win.rawValue ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
                                .appTextStyle()
                                .font(.caption2)
                                .frame(alignment: .center)
                                .padding(.bottom, 0.1)
                        } else {
                            Text(" ")
                        }
                        
                        Text(viewModel.dayFormatter.string(from: date))
                            .foregroundColor(viewModel.calendar.isDate(date, inSameDayAs: currentDate) ? Color.black : Color.white)
                            .appTextStyle()
                            .font(.caption)
                        
                        if let opponentText = viewModel.opponentText(date: date, teamID: teamID) {
                            Text(opponentText)
                                .foregroundColor(viewModel.calendar.isDate(date, inSameDayAs: currentDate) ? Color.black : Color.white)
                                .appTextStyle()
                                .font(.caption2)
                                .frame(alignment: .center)
                                .padding(.top, 0.1)
                        } else {
                            Text(" ")
                        }
                    }
                )
        }
    }
        
    // Trailing block for dates not in the month
    private func trailingBlock(date: Date) -> some View {
        Text(viewModel.dayFormatter.string(from: date))
            .foregroundColor(Color.black)
    }

    // Header block for days of the week
    private func headerBlock(date: Date) -> some View {
        Text(viewModel.weekDayFormatter.string(from: date))
            .appTextStyle()
            .font(.caption2)
    }

    // Title block for month changer
    private func titleBlock(date: Date) -> some View {
        HStack {
            Button {
                isCalendarLoaded = false
                changeMonth(by: -1)
            } label: {
                Label(title: { Text(ElementLabel.previous.rawValue) }, icon: { Image(systemName: Symbols.leftArrow.rawValue) })
                    .appTextStyle()
                    .labelStyle(IconOnlyLabelStyle())
            }
            
            Text(viewModel.monthFormatter.string(from: date).uppercased())
                .appTextStyle()
                .font(.footnote)
                .frame(width: 100)
                .padding(.vertical, Spacing.spacingExtraSmall)
                
            Button {
                isCalendarLoaded = false
                changeMonth(by: 1)
            } label: {
                Label(title: { Text(ElementLabel.next.rawValue) }, icon: { Image(systemName: Symbols.rightArrow.rawValue) })
                    .appTextStyle()
                    .labelStyle(IconOnlyLabelStyle())
            }
        }
        .padding([.leading, .bottom], Spacing.spacingExtraSmall)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
        
    // Change month forwards or backwards
    private func changeMonth(by value: Int) {
        guard let newMonth = viewModel.calendar.date(byAdding: .month, value: value, to: selectedDate) else {
            return
        }
        let components = viewModel.calendar.dateComponents([.year, .month], from: newMonth)
        var dateComponents = DateComponents()
        dateComponents.year = components.year
        dateComponents.month = components.month
        dateComponents.day = value > 0 ? 1 : viewModel.calendar.range(of: .day, in: .month, for: newMonth)?.count
        
        guard let newDate = viewModel.calendar.date(from: dateComponents) else {
            return
        }
        selectedDate = newDate
    }
}

struct CalendarGridView<Day: View, Header: View, Title: View, Trailing: View>: View {
    private var calendar: Calendar
    @Binding private var date: Date
    private let content: (Date) -> Day
    private let trailing: (Date) -> Trailing
    private let header: (Date) -> Header
    private let title: (Date) -> Title
    private let numDaysInWeek = 7
    
    public init(calendar: Calendar, date: Binding<Date>, @ViewBuilder content: @escaping (Date) -> Day, @ViewBuilder trailing: @escaping (Date) -> Trailing, @ViewBuilder header: @escaping (Date) -> Header, @ViewBuilder title: @escaping (Date) -> Title) {
        self.calendar = calendar
        self._date = date
        self.content = content
        self.trailing = trailing
        self.header = header
        self.title = title
    }
    
    var body: some View {
        let month = date.startOfMonth(using: calendar)
        let days = makeDays()
        
        LazyVGrid(columns: Array(repeating: GridItem(), count: numDaysInWeek)) {
            Section(header: title(month)) {
                ForEach(days.prefix(numDaysInWeek), id: \.self, content: header)
                ForEach(days, id: \.self) { date in
                    if calendar.isDate(date, equalTo: month, toGranularity: .month) {
                        content(date)
                    } else {
                        trailing(date)
                    }
                }
            }
        }
    }
}

extension CalendarGridView: Equatable {
    public static func == (lhs: CalendarGridView<Day, Header, Title, Trailing>, rhs: CalendarGridView<Day, Header, Title, Trailing>) -> Bool {
        lhs.calendar == rhs.calendar && lhs.date == rhs.date
    }
}

private extension CalendarGridView {
    func makeDays() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else {
            return []
        }

        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        return calendar.generateDays(for: dateInterval)
    }
}

private extension Calendar {
    func generateDates(for dateInterval: DateInterval, matching components: DateComponents) -> [Date] {
        var dates = [dateInterval.start]

        enumerateDates(startingAfter: dateInterval.start, matching: components, matchingPolicy: .nextTime) { date, _, stop in
            guard let date = date else { return }
            
            guard date < dateInterval.end else {
                stop = true
                return
            }

            dates.append(date)
        }
        
        return dates
    }

    func generateDays(for dateInterval: DateInterval) -> [Date] {
        generateDates(for: dateInterval, matching: dateComponents([.hour, .minute, .second], from: dateInterval.start)
        )
    }
}

private extension Date {
    func startOfMonth(using calendar: Calendar) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: self)) ?? self
    }
}

extension DateFormatter {
    convenience init(dateFormat: String, calendar: Calendar) {
        self.init()
        self.dateFormat = dateFormat
        self.calendar = calendar
    }
}
