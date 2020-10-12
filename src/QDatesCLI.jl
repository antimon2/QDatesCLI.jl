module QDatesCLI

using Comonicon
using QDates
using Dates

abstract type ARGType end

struct ShowQDate <: ARGType
    src::String
    qdt::QDate
end

struct ShowQDateAndDayname <: ARGType
    src::String
    qdt::QDate
end

struct ShowDate <: ARGType
    src::String
    dt::Date
end

struct ShowError <: ARGType
    src::String
    msg::String
end

function showresult(res::ShowQDate)
    println("$(res.src)は$(res.qdt)です。")
end

function showresult(res::ShowQDateAndDayname)
    println("$(res.src)は$(res.qdt)、$(QDates.dayname(res.qdt))です。")
end

function showresult(res::ShowDate)
    println("$(res.src)は西暦$(res.dt)です。")
end

function showresult(res::ShowError)
    println("$(res.src): $(res.msg)")
end

function parseargs(args::String...)
    results = ARGType[]
    if length(args) == 0
        push!(results, ShowQDateAndDayname("今日（$(Dates.today())）", QDates.today()))
    else
        for arg in args
            m = match(r"^(\d{3,4})-(\d{1,2})-(\d{1,2})$", arg)
            if !isnothing(m)
                try
                    dt = Date(parse(Int, m[1]), parse(Int, m[2]), parse(Int, m[3]))
                    push!(results, ShowQDate(arg, QDate(dt)))
                catch ex
                    if ex isa ArgumentError
                        push!(results, ShowError(arg, "不正な日付です。"))
                    else
                        push!(results, ShowError(arg, sprint(showerror, ex)))
                        rethrow(ex)
                    end
                end
                continue
            end
            m = match(r"^(\d{3,4})/(\d{1,2})/(\d{1,2})$", arg)
            if !isnothing(m)
                try
                    dt = Date(parse(Int, m[1]), parse(Int, m[2]), parse(Int, m[3]))
                    push!(results, ShowQDate(arg, QDate(dt)))
                catch ex
                    if ex isa ArgumentError
                        push!(results, ShowError(arg, "不正な日付、または対応範囲外の日付です。"))
                    else
                        push!(results, ShowError(arg, sprint(showerror, ex)))
                        rethrow(ex)
                    end
                end
                continue
            end
            m = match(r"^旧(\d{3,4})年(閏)?(\d{1,2})月(\d{1,2})日$", arg)
            if !isnothing(m)
                try
                    qdt = QDate(parse(Int, m[1]), parse(Int, m[3]), !isnothing(m[2]), parse(Int, m[4]))
                    push!(results, ShowDate(arg, Date(qdt)))
                catch ex
                    if ex isa ArgumentError
                        push!(results, ShowError(arg, "不正な日付、または対応範囲外の日付です。"))
                    else
                        push!(results, ShowError(arg, sprint(showerror, ex)))
                        rethrow(ex)
                    end
                end
                continue
            end
            m = match(r"^(一昨[昨々]日)|(一昨日)|(昨日)|(今日)|(明日)|(明後日)|(明[明々]後日)$", arg)
            if !isnothing(m)
                try
                    segment = Day(findfirst(!isnothing, m.captures) - 4)
                    push!(results, ShowQDate(arg, QDates.today() + segment))
                catch ex
                    if ex isa ArgumentError
                        push!(results, ShowError(arg, "不正な日付、または対応範囲外の日付です。"))
                    else
                        push!(results, ShowError(arg, sprint(showerror, ex)))
                        rethrow(ex)
                    end
                end
                continue
            end
            push!(results, ShowError(arg, "有効な日付として認識できません。"))
        end
    end
    results
end

"""
Show Kyūreki (旧暦) or Gregorian date for the corresponding date.
Multiple `<date_like>` arguments may be specified, and displays all the results.
When no arguments are specified, show Kyūreki information of `今日` (today).

- `<date_like>`: one of:  
    + Gregorian date (`yyyy-mm-dd`|`yyyy/mm/dd`)  
    + Kyūreki date (`旧yyyy年mm月dd日`|`旧yyyy年閏mm月dd日`)  
    + one of date_keywords ("今日"|"明日"|"明後日"|"明々後日"|"昨日"|"一昨日"|"一昨々日")

# Usage

qdate [<date_like> [<date_like> ...]]

# Arguments

- `args`: Some `<date_like>`s.
"""
@main function qdate(args::String...)
    for res in parseargs(args...)
        showresult(res)
    end
end
# @main function main(arg)
#     println("arg: $arg")
# end

end # module
